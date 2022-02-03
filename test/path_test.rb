require           'minitest/autorun'
require_relative  'test_helper.rb'

describe Platformer::Path do

  ### ONCE : ###################################################################
  describe 'when using traveled only ONCE paths' do 
    it 'gets instantiated' do
      p = Platformer::Path.new  [ [ 0, 0 ], [ -10, 0 ], [ -10, 20 ] ],
                                :once,
                                120     # in frames, so 2 seconds, but      ...
                                        # ... irrelevant for the :once type ...
                                        # ... because it ignores end pauses.

      assert_equal  :once,  p.type
      
      assert_equal  3,      p.subpaths.length
      assert_equal  ({ type: :movement, start: [0, 0], end: [ -10, 0], ud: [-1.0, 0.0] }),
                            p.subpaths[0]
      assert_equal  ({ type: :movement, start: [-10, 0], end: [ -10, 20], ud: [0.0, 1.0] }),
                            p.subpaths[1]
      assert_equal  ({ type: :end }),
                            p.subpaths[2]

      assert_equal  0,      p.index
    end

    it 'can travel through its subpaths' do
      p = Platformer::Path.new  [ [ 0, 0 ], [ -10, 0 ], [ -10, 20 ] ], :once, 120

      ### Step 1 :
      assert_equal  ({ type: :movement, start: [0, 0], end: [ -10, 0], ud: [-1.0, 0.0] }),
                    p.current_step

      ### Step 2:
      p.move_to_next_step
      assert_equal  ({ type: :movement, start: [-10, 0], end: [ -10, 20], ud: [0.0, 1.0] }),
                    p.current_step

      ### End step :
      p.move_to_next_step
      assert_equal  ({ type: :end }),
                    p.current_step

      ### We can't go any further :
      p.move_to_next_step
      assert_equal  ({ type: :end }),
                    p.current_step
    end
  end


  ### LOOP : ###################################################################
  describe 'when using a LOOPED path' do
    it 'gets instanciated WITHOUT a pause before looping' do
      p = Platformer::Path.new  [ [ 0, 0 ], [ -10, 0 ], [ -10, 20 ] ],
                                :loop,
                                0       # 0 means no pause

      assert_equal  :loop,  p.type
      
      assert_equal  2,      p.subpaths.length
      assert_equal  ({ type: :movement, start: [0, 0], end: [ -10, 0], ud: [-1.0, 0.0] }),
                            p.subpaths[0]
      assert_equal  ({ type: :movement, start: [-10, 0], end: [ -10, 20], ud: [0.0, 1.0] }),
                            p.subpaths[1]

      assert_equal  0,      p.index
    end

    it 'gets instanciated WITH a pause before looping' do
      p = Platformer::Path.new  [ [ 0, 0 ], [ -10, 0 ], [ -10, 20 ] ],
                                :loop,
                                60      # 60 frames, so 1s

      assert_equal  :loop,  p.type
      
      assert_equal  3,      p.subpaths.length
      assert_equal  ({ type: :movement, start: [0, 0], end: [ -10, 0], ud: [-1.0, 0.0] }),
                            p.subpaths[0]
      assert_equal  ({ type: :movement, start: [-10, 0], end: [ -10, 20], ud: [0.0, 1.0] }),
                            p.subpaths[1]
      assert_equal  ({ type: :pause, duration: 60 }),
                            p.subpaths[2]

      assert_equal  0,      p.index
    end

    it 'can travel through its subpaths' do
      p = Platformer::Path.new  [ [ 0, 0 ], [ -10, 0 ], [ -10, 20 ] ], :loop, 60

      ### Step 1 :
      assert_equal  ({ type: :movement, start: [0, 0], end: [ -10, 0], ud: [-1.0, 0.0] }),
                    p.current_step

      ### Step 2:
      p.move_to_next_step
      assert_equal  ({ type: :movement, start: [-10, 0], end: [ -10, 20], ud: [0.0, 1.0] }),
                    p.current_step

      ### Pause step at the end :
      p.move_to_next_step
      assert_equal  ({ type: :pause, duration: 60 }),
                    p.current_step

      ### Back to step 1 :
      p.move_to_next_step
      assert_equal  ({ type: :movement, start: [0, 0], end: [ -10, 0], ud: [-1.0, 0.0] }),
                    p.current_step
    end
  end


  ### PINGPONG : ###############################################################
  describe 'when using a PINGPONG looped path' do
    it 'gets instanciated WITHOUT a pause before looping' do
      p = Platformer::Path.new  [ [ 0, 0 ], [ -10, 0 ], [ -10, 20 ] ],
                                :pingpong,
                                0       # 0 means no pause

      assert_equal  :pingpong,  p.type
      
      assert_equal  4,          p.subpaths.length
      assert_equal  ({ type: :movement, start: [0, 0], end: [ -10, 0], ud: [-1.0, 0.0] }),
                                p.subpaths[0]
      assert_equal  ({ type: :movement, start: [-10, 0], end: [ -10, 20], ud: [0.0, 1.0] }),
                                p.subpaths[1]
      assert_equal  ({ type: :movement, start: [-10, 20], end: [ -10, 0], ud: [0.0, -1.0] }),
                                p.subpaths[2]
      assert_equal  ({ type: :movement, start: [-10, 0], end: [ 0, 0], ud: [1.0, 0.0] }),
                                p.subpaths[3]

      assert_equal  0,          p.index
    end

    it 'gets instanciated WITH a pause before looping' do
      p = Platformer::Path.new  [ [ 0, 0 ], [ -10, 0 ], [ -10, 20 ] ],
                                :pingpong,
                                120     # 120 frames, so 2s

      assert_equal  :pingpong,  p.type
      
      assert_equal  6,          p.subpaths.length
      assert_equal  ({ type: :movement, start: [0, 0], end: [ -10, 0], ud: [-1.0, 0.0] }),
                                p.subpaths[0]
      assert_equal  ({ type: :movement, start: [-10, 0], end: [ -10, 20], ud: [0.0, 1.0] }),
                                p.subpaths[1]
      assert_equal  ({ type: :pause, duration: 120 }),
                                p.subpaths[2]
      assert_equal  ({ type: :movement, start: [-10, 20], end: [ -10, 0], ud: [0.0, -1.0] }),
                                p.subpaths[3]
      assert_equal  ({ type: :movement, start: [-10, 0], end: [ 0, 0], ud: [1.0, 0.0] }),
                                p.subpaths[4]
      assert_equal  ({ type: :pause, duration: 120 }),
                                p.subpaths[5]

      assert_equal  0,          p.index
    end

    it 'can travel through its subpaths' do
      p = Platformer::Path.new  [ [ 0, 0 ], [ -10, 0 ], [ -10, 20 ] ], :pingpong, 120

      ### Step 1 :
      assert_equal  ({ type: :movement, start: [0, 0], end: [ -10, 0], ud: [-1.0, 0.0] }),
                    p.current_step

      ### Step 2:
      p.move_to_next_step
      assert_equal  ({ type: :movement, start: [-10, 0], end: [ -10, 20], ud: [0.0, 1.0] }),
                    p.current_step

      ### Pause step :
      p.move_to_next_step
      assert_equal  ({ type: :pause, duration: 120 }),
                    p.current_step

      ### Step 3, meaning step 2 backwards :
      p.move_to_next_step
      assert_equal  ({ type: :movement, start: [-10, 20], end: [-10, 0], ud: [0.0, -1.0] }),
                    p.current_step

      ### Step 4, meaning step 1 backwards :
      p.move_to_next_step
      assert_equal  ({ type: :movement, start: [-10, 0], end: [0, 0], ud: [1.0, 0.0] }),
                    p.current_step

      ### Pause step at the end :
      p.move_to_next_step
      assert_equal  ({ type: :pause, duration: 120 }),
                    p.current_step

      ### Back to step 1 :
      p.move_to_next_step
      assert_equal  ({ type: :movement, start: [0, 0], end: [ -10, 0], ud: [-1.0, 0.0] }),
                    p.current_step
    end
  end
end
