module KMP3D
  module Observer
    def activate
      @dlg.show unless @dlg.visible?
      @id = Data.model.tools.active_tool_id
      refresh_html
      update_comp
    end

    def update_comp
      Data.model.start_operation("Add KMP3D Point")
      @comp = Data.model.active_entities.add_instance(type.model, IDENTITY)
      @comp.visible = false
      @prev_comp = @comp
      @undone = true
    end

    def deactivate(view)
      Data.model.abort_operation
      view.invalidate
    end

    def onMouseMove(flags, x, y, view)
      @comp.visible = false
      @ip.pick(view, x, y)
      ent = get_ent(x, y, view)
      if combine_settings?(ent)
        view.tooltip = "Add settings to point"
      else
        @comp = type.transform(@prev_comp.copy, @ip.position)
        @comp.definition = type.model
        view.tooltip = @ip.tooltip if @ip.valid?
      end
      Sketchup.status_text = type.helper_text
      view.invalidate
    end

    def onLButtonDown(flags, x, y, view)
      @ip.pick(view, x, y)
      ent = get_ent(x, y, view)
      return if !@ip.valid? || type.on_external_settings?
      if combine_settings?(ent)
        ent.name += type.component_settings unless ent.type?(type.type_name)
        Data.model.commit_operation
        update_comp
      elsif type.advance_steps(@ip.position) == 0
        @comp.name = "KMP3D " + type.component_settings
        Data.model.commit_operation
        update_comp
      end
      @prev_comp = @comp
      refresh_html
    end

    def draw(view)
      @ip.draw(view)
    end

    def onSelectionBulkChange(_)
      refresh_html
    end

    def onSelectionCleared(_)
      refresh_html
    end

    def onOpenModel(_)
      Data.reload(self)
      refresh_html
    end

    def onPreSaveModel(_)
      Data.types.each { |type| type.save_settings }
    end

    def onTransactionUndo(_)
      return unless @id == Data.model.tools.active_tool_id && @undone
      @undone = false # prevent recursion
      Sketchup.undo # call a second undo since new operation has already started
      update_comp
      refresh_html
    end

    def onTransactionRedo(_)
      return unless @id == Data.model.tools.active_tool_id
      refresh_html
    end

    private

    def combine_settings?(ent)
      ent && ent.kmp3d_object? && type.enable_combine? && !ent.type?("CKPT")
    end

    def get_ent(x, y, view)
      ph = view.pick_helper
      ph.do_pick(x, y)
      ent = ph.best_picked
      return ent
    end
  end
end
