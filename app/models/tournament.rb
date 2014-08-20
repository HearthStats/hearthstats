class Tournament < ActiveRecord::Base
  attr_accessible :bracket_format, :creator_id, :id, :name, :num_players

  has_many :tourn_users
  has_many :users, through: :tourn_users
  has_many :tourn_pairs
  has_many :tourn_decks
  has_many :decks, through: :tourn_decks
  ### CLASS METHODS:
  ### INSTANCE METHODS:

  def initiate_groups(num_pods)
    user_list = TournUser.where(tournament_id: self.id)
    user_list = user_list.shuffle
    num_residual_users = user_list.count % num_pods
    pair_list = Array.new
    (1..num_pods).each do |pod|
      pod_size = (user_list.count / num_pods).floor + (num_residual_user / num_pods).ceil
      pod_list = user_list.shift(pod_size)
      num_residual_user -= 1 if num_residual_user.nonzero?
      pairings = pod_list.combination(2).to_a
      pairings.each do |pairing|
        new_pair = self.tourn_pairs.build(tournament_id: self.id, 
                            pos: pod,
                            p1_id: pairing[0].id,
                            p2_id: pairing[1].id,
                            undecided: -1)
        pair_list.push[new_pair]
      end
    end

    TournPair.import pair_list

  end

  def initiate_brackets
    @user_list = TournUser.where(tournament_id: self.id)
    format = self.bracket_format

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

    @user_list.each do |user|
      pair = base_pairs.fetch(base_pair_pointer)
      new_pair = self.tourn_pairs.build(tournament_id: self.id, 
                                  pos: (pair.pos*2 + extend_left_flag),
                                  roundof: (pair.roundof * 2),
                                  p1_id: pair.p2_id,
                                  p2_id: user.id,
                                  undecided: -1)
      base_pair_pointer = (base_pair_pointer + 2) % (base_pairs.count - 1)    # wrap around into odd indices
      pair_list.push(new_pair)

      if base_pair_pointer == base_pairs.count - 1  # extended right child of every base pair, now do left
        extend_left_flag = 0
      end

    end

    TournPair.import pair_list

    update_undecided_pair_ids

  end

  private
  def update_undecided_pair_ids
    final_pair_list = TournPair.where(tournament_id: self.id)
    root = final_pair_list.select { |p| (!p.nil? && p.roundof == 2 && p.pos == 0) }
    p_queue = []
    p_queue.push(root[0]) # roundof: 2, pos: 0
    while !p_queue.empty? do

      current = p_queue.shift
      left = final_pair_list.select { |x| (!x.nil? && x.roundof == (current.roundof * 2) && x.pos == current.pos*2) }
      right = final_pair_list.select { |y| (!y.nil? && y.roundof == (current.roundof * 2) && y.pos == (current.pos*2 + 1)) }
      if !left.empty?
        TournPair.update(current.id, p1_id: left[0].id)
        p_queue.push(left[0])
      end

      if !right.empty?
        TournPair.update(current.id, p2_id: right[0].id)
        p_queue.push(right[0])
      end

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
                                  pos: (pair.pos*2),
                                  roundof: (pair.roundof * 2),
                                  p1_id: left_user1_id,
                                  p2_id: left_user2_id,
                                  undecided: left_user1_id.nil? ? 2 : -1)

        right = self.tourn_pairs.build(tournament_id: self.id, 
                                  pos: (pair.pos*2 + 1),
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
