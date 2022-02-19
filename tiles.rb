#
#  tiles.rb
#


class Block < GameObject
    def initialize(image)
        super(image)
        @can_move = true
    end

    def interaction_results
        [RDIA_REACT_BOUNCE, RDIA_REACT_CONSUME, RDIA_REACT_SCORE]
    end

end



class Wall < GameObject
    def initialize(image)
        super(image)
        @can_move = false
    end

    def interaction_results
        [RDIA_REACT_STOP]
    end
end

class Brick < GameObject
    def initialize(image)
        super(image)
        @can_move = false
    end

    def interaction_results
        [RDIA_REACT_BOUNCE, RDIA_REACT_CONSUME, RDIA_REACT_SCORE]
    end

    def score 
        10 
    end
end

class Dot < GameObject
    def initialize(image)
        super(image)
        @can_move = false
    end

    def interaction_results
        [RDIA_REACT_CONSUME, RDIA_REACT_SCORE]
    end

    def score 
        50 
    end
end

class OutOfBounds < GameObject
    def initialize(image)
        super(image)
        @can_move = false
    end

    def interaction_results
        [RDIA_REACT_LOSE, RDIA_REACT_STOP]
    end
end

class BackgroundArea < GameObject
    def initialize(image)
        super(image)
        @can_move = false
    end

    def widget_z
        Z_ORDER_SELECTION_BACKGROUND
    end
end

class ForegroundArea < GameObject
    def initialize(image)
        super(image)
        @can_move = false
    end

    def widget_z
        Z_ORDER_TEXT
    end
end

class GoalArea < GameObject
    def initialize(image)
        super(image)
        @can_move = false
    end

    def interaction_results
        [RDIA_REACT_GOAL, RDIA_REACT_STOP]
    end
end
