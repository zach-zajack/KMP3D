module KMP3D
  class Type
    include Table
    include HTMLHelpers

    attr_reader :name, :external_settings, :settings
    attr_accessor :group, :table, :step

    Settings = Struct.new(:type, :input, :prompt, :default, :opts)

    def initialize
      @group = 0
      @step = 0
      if @external_settings # external settings deal with groups, mostly
        @table = Data.model.get_attribute("KMP3D", type_name, \
           [Array.new(@external_settings.length)])
        add_group(true) if @table.length == 1
      end
    end

    def model
      Data.load_def("point")
    end

    def vector?
      false
    end

    def object?
      false
    end

    def checkpoint?
      false
    end

    def camera?
      false
    end

    def hybrid?
      false
    end

    def hide_point?
      false
    end

    def sequential_id?
      false
    end

    def draw_connected_points(view, pos, selection=false)
    end

    def save_settings
      return unless @external_settings
      Data.model.set_attribute("KMP3D", type_name, @table)
    end

    def add_group(_init=false)
      return unless @external_settings
      @table << @external_settings.map { |s| s.default }
    end

    def component_settings
      "#{type_name}(#{group_id(@group)}|#{inputs[-1][2..-1] * '|'}) "
    end

    def table_helper_text
    end

    def inputs
      # settings added due to next point using previous settings
      inputs = [[-1, false] + @settings.map { |s| s.default }]
      Data.entities_in_group(type_name, group_id(@group)).each do |ent|
        id = ent.kmp3d_id(type_name)
        selected = Data.selection.include?(ent)
        inputs << [id, selected] + ent.kmp3d_settings[1..-1]
      end
      return inputs
    end

    def group_id(i)
      i
    end

    def select_point(ent)
    end

    def update_setting(ent, value, col)
      ent.edit_setting(col.to_i + 1, value)
    end

    def update_group(value, row, col)
      @table[row.to_i + 1][col.to_i] = value
    end

    def type_name
      self.class.name[7..-1]
    end

    def groups
      @external_settings.nil? ? 1 : @table.length - 1
    end

    def on_external_settings?
      @group == groups
    end

    def settings_name
      "Group"
    end

    def add_comp(comp)
      comp.name = "KMP3D " + component_settings
      return comp
    end

    def generate_next_groups_table
      @next_groups_table = table[1..-1].map do |row|
        row[0].split(",").map { |i| i.to_i }
      end
    end

    def next_groups(row)
      @next_groups_table[row]
    end

    def prev_groups(row)
      @next_groups_table.each do |next_grps|
        next unless next_grps.include?(row)
        return groups.times.select { |i| @next_groups_table[i] == next_grps }
      end
      return [] # if no groups found
    end
  end
end
