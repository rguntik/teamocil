module Teamocil
  module Tmux
    class Session < ClosedStruct.new(:name, :windows)
      def initialize(object)
        super

        # Sessions need a name
        self.name = "teamocil-session-#{rand(1_000_000)}" unless name

        self.windows = windows.each_with_index.map do |window, index|
          # Windows need to know their position
          window.merge! index: index

          Teamocil::Tmux::Window.new(window)
        end
      end

      def as_tmux
        [].tap do |tmux|
          tmux << Teamocil::Command::RenameSession.new(name: name)
          tmux << windows.map(&:as_tmux)

          # Set the focus on the right window or do nothing
          focused_window = windows.find(&:focus)
          tmux << Teamocil::Command::SelectWindow.new(index: focused_window.internal_index) if focused_window
        end.flatten
      end
    end
  end
end
