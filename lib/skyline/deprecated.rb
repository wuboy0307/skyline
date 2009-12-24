module Skyline

  # @deprecated  Don't use Skyline::ContentItem anymore, use Skyline::BelongsToReferable (will be removed in 3.1.0)
  module ContentItem
    
    def self.included(base)
      warn "[DEPRECATION] Don't use Skyline::ContentItem anymore, use Skyline::BelongsToReferable (will be removed in 3.1.0)"
      
      base.send(:include, Skyline::BelongsToReferable)
      
      base.class_eval do
        named_scope(:published, {}) unless method_defined?(:published)
        
        named_scope(:with_site, {}) unless method_defined?(:with_site)
      end
      
      class << base 
        alias_method :referable_content, :belongs_to_referable
      end
    
    end    
  end
  
  # @deprecated Don't use Skyline::Referable anymore, use Skyline::HasManyReferablesIn (will be removed in 3.1.0)
  module Referable
    def self.included(base)
      warn "[DEPRECATION] Don't use Skyline::Referable anymore, use Skyline::HasManyReferablesIn (will be removed in 3.1.0)"
            
      base.send(:include, Skyline::HasManyReferablesIn)
      class << base 
        alias_method :referable_field, :has_many_referables_in
      end      
    end
  end
  
  # @deprecated Don't use Skyline::SectionItem anymore, use Skyline::Sections::Interface (will be removed in 3.1.0)
  module SectionItem
    def self.included(base)
      warn "[DEPRECATION] Don't use Skyline::SectionItem anymore, use Skyline::Sections::Interface (will be removed in 3.1.0)"
      
      base.send(:include, Skyline::Sections::Interface)
    end
  end
  
  # @deprecated Don't use Skyline::FormBuilderWithErrors anymore, use Skyline::FormBuilder (will be removed in 3.1.0)
  module FormBuilderWithErrors
    def self.included(base)
      warn "[DEPRECATION] Don't use Skyline::FormBuilderWithErrors anymore, use Skyline::FormBuilder (will be removed in 3.1.0)"
      
      base.send(:include, Skyline::FormBuilder)
    end
  end
  
  # @deprecated "[DEPRECATION] Don't use Skyline::Renderer anymore, use Skyline::Rendering::Renderer (will be removed in 3.1.0)"
  class Skyline::Renderer < Skyline::Rendering::Renderer
    class << self
      %w{renderables register_renderables renderable_types helper}.each do |m|
        define_method(m) do |*args|
          deprecate!
          super
        end
      end
      
      def deprecate!
        warn "[DEPRECATION] Don't use Skyline::Renderer anymore, use Skyline::Rendering::Renderer (will be removed in 3.1.0)"
      end
    end
    
    def initialize(*args)
      self.class.deprecate!
      super
    end
    
  end
    
end
