module ActionController
  class Base < Http
    abstract!
    
    use AbstractController::Callbacks
    use AbstractController::Helpers
    use AbstractController::Logger

    use ActionController::HideActions
    use ActionController::UrlFor
    use ActionController::Renderer
    use ActionController::Layouts
    
    # Legacy modules
    include SessionManagement
    
    # Rails 2.x compatibility
    use ActionController::Rails2Compatibility
    
    def self.inherited(klass)
      ::ActionController::Base.subclasses << klass.to_s
      super
    end
    
    def self.subclasses
      @subclasses ||= []
    end
    
    def self.app_loaded!
      @subclasses.each do |subclass|
        subclass.constantize._write_layout_method
      end
    end
    
    def render(action = action_name, options = {})
      if action.is_a?(Hash)
        options, action = action, nil 
      else
        options.merge! :action => action
      end
      
      super(options)
    end
    
    def render_to_body(options = {})
      options = {:template => options} if options.is_a?(String)
      super
    end
    
    def process_action
      ret = super
      render if response_body.nil?
      ret
    end
    
    def respond_to_action?(action_name)
      super || view_paths.find_by_parts?(action_name.to_s, {:formats => formats, :locales => [I18n.locale]}, controller_path)
    end
  end
end