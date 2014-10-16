class Tournament < ActiveRecord::Base
  attr_accessible :bracket_format, :admin_ids, :id, :name, :num_players,
                  :desc, :is_private, :num_pods, :started, :num_decks, :code, :best_of, :creator_id

  ##
  # bracket_format
  # 0: Group
  # 1: Single Elimination
  # 2: Double Elimination
  #

  ##validates_uniqueness_of :code, allow_nil: true
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
    success = false
    self.started = true
    no_deck_players = []
    # check if all decks are submitted
    self.tourn_users.each do |player|
      if !player.decks_submitted?
        no_deck_players.push(player.user.name + "(" + player.id.to_s + ")")
      end
    end
    if !no_deck_players.empty?
      message = "Following players have not submitted decks: " + no_deck_players.join(",")
      admins = User.with_role(:tourn_admin, self)
      admins.each do |admin|
        admin.notify("Decks not submitted", message)
      end
      return false
    end

    case self.bracket_format
    when 0
      success = initiate_groups(self.num_pods)
    when 1
      success = initiate_brackets
    end
    success
  end

  def started?
    self.started
  end

  def is_user_competing(user_id)
    t_users = TournUser.where(tournament_id: id)
    t_users.each do |t_user|
      if t_user.user_id == user_id
        return true
      end
    end
    false
  end

  def get_num_pairings_in_pod(pod_number)
    self.tourn_pairs.select{ |p| p.pos == pod_number}.count if self.bracket_format == 0
  end

  def initiate_groups(num_pods)
    user_list = TournUser.where(tournament_id: self.id)
    user_list = user_list.shuffle
    num_residual_users = user_list.count % num_pods
    num_users_per_pod = (user_list.count / num_pods).floor

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
      end
    end
    self.save
    true
  end

  def initiate_pod(pod, player_emails_string)
    player_emails = player_emails_string.split(",")
    user_list = []
    invalid_emails = []
    player_emails.each do |email|
      user = User.where(email: email).first
      if !user.nil?
        t_user = TournUser.where(tournament_id: id, user_id: user.id).first
        user_list.push(t_user)
      else
        invalid_emails.push(email)
      end
    end
    pairings = user_list.combination(2).to_a
    pairings.each do |pairing|
      new_pair = TournPair.create(tournament_id: id,
                                  pos: pod,
                                  p1_id: pairing[0].id,
                                  p2_id: pairing[1].id,
                                  undecided: -1)
    end
    invalid_emails
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
      if base_pair_pointer == base_pairs.count - 1  # extended right child of every base pair, now do left
        extend_left_flag = 0
        base_pair_pointer = -2      # reset it to wrap around to 0th position
      end

      base_pair_pointer += 2
      if base_pair_pointer != (base_pairs.count - 1)     # when the pointer is about to become the last index, we don't want it to wrap around
        base_pair_pointer %= (base_pairs.count - 1)    # wrap around into odd indices
      end
    end
    self.save
    update_undecided_pair_ids
    true
  end

  def is_group_stage?
    Tournament.format_to_s(self.bracket_format) === "Group Stage"
  end

  def invite_only?
    self.is_private == true
  end

  def find_winner_id
    TournPair.where(tournament_id: id, roundof: 2).first.winner_id
  end

  def find_pod_winner_id(pod)
    pairs = TournPair.where(tournament_id:self.id, pos: pod)
    scores = Hash.new
    scores.default = 0
    pairs.each do |pair|
      if pair.winner_id.nil?
        return -1     # returns -1 if unresolved pairings
      else
        scores[pair.winner_id] += 1
      end
    end
    scores = scores.sort_by{ |player, score| score }.reverse
    scores.first.first
  end

  def get_pod_standings(pod)
    players = Hash.new
    pairs = TournPair.where(tournament_id: id, pos: pod)
    pairs.each do |pair|
      if !players.has_key?(pair.p1_id)
        user = TournUser.find(pair.p1_id)
        players[pair.p1_id] = {id: user.id, name: user.user.name, score: pair.get_p1_score}
      else
        players[pair.p1_id][:score] += pair.get_p1_score
      end

      if !players.has_key?(pair.p2_id)
        user = TournUser.find(pair.p2_id)
        players[pair.p2_id] = {id: user.id, name: user.user.name, score: pair.get_p2_score}
      else
        players[pair.p2_id][:score] += pair.get_p2_score
      end
    end
    players = players.values
    players.sort_by { |ps| ps[:score] }.reverse
  end

  private

  def solve_players(num_pairs)
    c = num_pairs*2*(-1)
    (1 - Math.sqrt(1 - 4*c)) / 2
  end

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
        undecided += 1
      end

      if !right.nil?
        TournPair.update(current.id, p2_id: right.id)
        p_queue.push(right)
        undecided += 2
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
    pair_list
  end
end
