class Tournament < ActiveRecord::Base
  attr_accessible :bracket_format, :admin_ids, :id, :name, :num_players,
                  :desc, :is_private, :num_pods, :started, :num_decks, :code, :best_of

  ##
  # bracket_format
  # 0: Group
  # 1: Single Elimination
  # 2: Double Elimination
  #

  validates_uniqueness_of :code, allow_nil: true
  validates :name, presence: true
  validates :num_decks, presence: true
  validates :best_of, presence: true
  validates :num_pods, presence: true, if: :is_group_stage?
  validates :code, presence: true, if: :invite_only?

  ### ASSOCIATIONS:

  has_many :tourn_users
  has_many :users, through: :tourn_users
  has_many :tourn_pairs
  has_many :tourn_decks
  has_many :decks, through: :tourn_decks

  ### CLASS METHODS:
  def self.all_formats
    [['Single Elimination', 1],['Group Stage', 0]]
  end

  def self.format_to_s(format)
    if format.is_a? String
      format = Integer(format)
    end

    case format
    when 0
      return "Group Stage"
    when 1
      return "Single Elimination"
    end
  end

  ### INSTANCE METHODS:
  def start_tournament
    case self.bracket_format
    when 0
      initiate_groups(self.num_pods)
    when 1
      initiate_brackets
    end
  end

  def started?
    self.started
  end

  def get_num_pairings_in_pod(pod_number)
    self.tourn_pairs.select{ |p| p.pos == pod_number}.count if self.bracket_format == 0
  end

  def initiate_groups(num_pods)
    user_list = TournUser.where(tournament_id: self.id)
    user_list = user_list.shuffle
    num_residual_users = user_list.count % num_pods
    num_users_per_pod = (user_list.count / num_pods).floor
    pair_list = Array.new

    (1..num_pods).each do |pod|
      pod_size = num_users_per_pod + (num_residual_users.quo(num_pods)).ceil
      pod_list = user_list.shift(pod_size)
      num_residual_users -= 1 if num_residual_users.nonzero?
      pairings = pod_list.combination(2).to_a
      pairings.each do |pairing|
        new_pair = self.tourn_pairs.build(tournament_id: self.id,
                                          pos: pod,
                                          p1_id: pairing[0].id,
                                          p2_id: pairing[1].id,
                                          undecided: -1)
        pair_list.push(new_pair)
      end
    end

    TournPair.import pair_list
  end

  def initiate_brackets
    @user_list = TournUser.where(tournament_id: self.id)
    format = bracket_format

    if @user_list.length < 4
      return
    end

    @user_list = @user_list.shuffle
    depth = Math.log2(@user_list.length).floor
    #the list of pairings we want to save eventually
    pair_list = bfs_populate(depth)
    base_pairs = pair_list.select { |p| p.roundof == 2**depth }

    base_pair_pointer = 0

    extend_left_flag = 1  # start extending the left child of base pairs

    base_pair_offset = 2**depth - 1

    @user_list.each do |user|
      pair = base_pairs.fetch(base_pair_pointer)
      new_pair_pos = pair.pos*2 + extend_left_flag
      new_pair = self.tourn_pairs.build(tournament_id: self.id,
                                        pos: new_pair_pos,
                                        roundof: (pair.roundof * 2),
                                        p1_id: extend_left_flag.zero? ? pair.p1_id : pair.p2_id,
                                        p2_id: user.id,
                                        undecided: -1)

      pair_list.insert(base_pair_offset + base_pair_pointer, new_pair)

      if base_pair_pointer == base_pairs.count - 1  # extended right child of every base pair, now do left
        extend_left_flag = 0
        base_pair_pointer = -2      # reset it to wrap around to 0th position
      end

      base_pair_pointer += 2
      if base_pair_pointer != (base_pairs.count - 1)     # when the pointer is about to become the last index, we don't want it to wrap around
        base_pair_pointer %= (base_pairs.count - 1)    # wrap around into odd indices
      end

    end
    pair_list.reject! { |p| p.nil? }
    TournPair.import pair_list

    update_undecided_pair_ids
  end

  def is_group_stage?
    Tournament.format_to_s(self.bracket_format) === "Group Stage"
  end

  def invite_only?
    self.is_private == true
  end

  private

  def update_undecided_pair_ids
    final_pair_list = TournPair.where(tournament_id: self.id)
    root = final_pair_list.select { |p| (!p.nil? && p.roundof == 2 && p.pos == 0) }
    p_queue = []
    p_queue.push(root[0]) # roundof: 2, pos: 0

    while !p_queue.empty? do
      undecided = -1
      current = p_queue.shift
      left = final_pair_list.find { |x| (x.roundof == (current.roundof * 2) && x.pos == current.pos * 2) }
      right = final_pair_list.find { |y| (y.roundof == (current.roundof * 2) && y.pos == (current.pos * 2 + 1)) }
      if !left.nil?
        TournPair.update(current.id, p1_id: left.id)
        p_queue.push(left)
        undecided += 2
      end

      if !right.nil?
        TournPair.update(current.id, p2_id: right.id)
        p_queue.push(right)
        undecided += 1
      end

      TournPair.update(current.id, undecided: undecided)
    end
  end

  def bfs_populate(depth)
    queue = Array.new
    root = self.tourn_pairs.build(tournament_id: self.id, 
                                  pos: 0,
                                  roundof: 2,
                                  undecided: 2)
    queue.push(root)
    pair_list = Array.new
    pair_list.push(queue[0])  # push initial root pairing into list

    left_user1_id = nil
    left_user2_id = nil
    right_user1_id = nil
    right_user2_id = nil

    while !queue.empty? do

      pair = queue.shift
      if Math.log2(pair.roundof) < depth     # populate down to "lower bound" level

        if Math.log2(pair.roundof) == (depth - 1)  # at the bottom level (excluding residual users)
          left_user1_id = @user_list.shift.id
          left_user2_id = @user_list.shift.id
          right_user1_id = @user_list.shift.id
          right_user2_id = @user_list.shift.id
        end

        left = self.tourn_pairs.build(tournament_id: self.id,
                                      pos: (pair.pos * 2),
                                      roundof: (pair.roundof * 2),
                                      p1_id: left_user1_id,
                                      p2_id: left_user2_id,
                                      undecided: left_user1_id.nil? ? 2 : -1)

        right = self.tourn_pairs.build(tournament_id: self.id,
                                      pos: (pair.pos * 2 + 1),
                                      roundof: (pair.roundof * 2),
                                      p1_id: right_user1_id,
                                      p2_id: right_user2_id,
                                      undecided: right_user1_id.nil? ? 2 : -1)

        pair_list.push(left)
        pair_list.push(right)
        queue.push(left)
        queue.push(right)

        left_user1_id = nil
        left_user2_id = nil
        right_user1_id = nil
        right_user2_id = nil
      end

    end
    puts pair_list.count
    pair_list
  end
end
