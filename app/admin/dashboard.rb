ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => 'Dashboard'

  content :title => 'Dashboard' do
    div :class => "blank_slate_container", :id => "dashboard_default_message" do
      h2 'HearthStats Dashboard'
      small 'Some basic functionality'
    end

    # Here is an example of a simple dashboard with columns and panels.

    columns do
      column do
        panel "Recent Decks" do
          ul do
            Deck.last(5).map do |deck|
              li link_to(deck.name, deck)
            end
          end
        end
      end

      column do
        panel "Export" do
          small 'Click to export data for the current season'
          ul do
            li link_to "Ranked CSV", admin_export_con_path(format: "csv")
            li link_to "Arena CSV", admin_export_arena_path(format: "csv")
          end
        end
      end
    end
  end # content
end
