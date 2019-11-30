module KMP3D
  module Data
    module_function

    def model
      Sketchup.active_model
    end

    def entities
      model.active_entities
    end

    def selection
      model.selection
    end

    def layers
      model.layers
    end

    def model_dir
      path = Data.model.path
      rindex = path.rindex(/[\\\/]/)
      return "" if rindex.nil?
      return path[0..rindex]
    end

    def model_name
      path = Data.model.path
      rindex = path.rindex(/[\\\/]/)
      return "untitled" if rindex.nil?
      return path[rindex + 1...-4]
    end

    def set_layer_visible(type_name)
      @types.each { |type| layers[type.name].visible = type.name == type_name }
    end

    def kmp3d_entities(type_name)
      entities.select { |ent| ent.type?(type_name) }
    end

    def entities_in_group(type_name, group)
      entities.select do |ent|
        ent.type?(type_name) && ent.kmp3d_group == group
      end
    end

    def entities_before_group(type_name, group)
      entities.select do |ent|
        ent.type?(type_name) && ent.kmp3d_group < group
      end
    end

    def entities_after_group(type_name, group)
      entities.select do |ent|
        ent.type?(type_name) && ent.kmp3d_group > group
      end
    end

    def get_entity(type_name, id)
      return kmp3d_entities(type_name)[id.to_i]
    end

    def types
      @types
    end

    def type_by_name(name)
      @types.select { |type| type.type_name == name }.first
    end

    def hybrid_types
      @hybrid_types
    end

    def load_def(name)
      model.definitions.load("#{DIR}/models/#{name}.skp")
    end

    def load_kmp3d_model
      return if model.get_attribute("KMP3D", "KMP3D-model?", false)
      Dir["#{DIR}/models/*.skp"].each { |d| model.definitions.load(d) }
      @types.each { |t| layers.add(t.name).visible = false }
      model.set_attribute("KMP3D", "KMP3D-model?", true)
    end

    def reload(observer)
      model.add_observer(observer)
      selection.add_observer(observer)
      @types = [
        KTPT.new, ENPT.new, ITPT.new, CKPT.new, GOBJ.new, POTI.new,
        AREA.new, JGPT.new, CNPT.new, MSPT.new, STGI.new, Hybrid.new
      ]
      @hybrid_types = [
        KTPT.new, ENPT.new, ITPT.new,
        POTI.new, JGPT.new, CNPT.new, MSPT.new
      ]
    end
  end
end
