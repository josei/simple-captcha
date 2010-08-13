require 'simple_captcha/utils'
require 'simple_captcha/image'
require 'simple_captcha/view'
require 'simple_captcha/controller'

if Object.const_defined?("ActionView")
  ActionView::Base.send(:include, SimpleCaptcha::ViewHelper)
  ActionView::Helpers::FormBuilder.send(:include, SimpleCaptcha::FormBuilder)
end

if Object.const_defined?("ActiveRecord")
  require 'simple_captcha/active_record'
  ActiveRecord::Base.send(:include, SimpleCaptcha::ModelHelpers)
end

if Object.const_defined?("Formtastic")
  require 'simple_captcha/formtastic'
  Formtastic::SemanticFormHelper.builder = SimpleCaptcha::CustomFormBuilder
end

module SimpleCaptcha
  # Attribute for test environments
  mattr_accessor :value
  @@value = false

  mattr_accessor :image_size
  @@image_size = "100x28"
  
  mattr_accessor :length
  @@length = 5
  
  # 'embosed_silver',
  # 'simply_red',
  # 'simply_green',
  # 'simply_blue',
  # 'distorted_black',
  # 'all_black',
  # 'charcoal_grey',
  # 'almost_invisible'
  # 'random'
  mattr_accessor :image_style
  @@image_style = 'simply_blue'
  
  # 'low', 'medium', 'high', 'random'
  mattr_accessor :distortion
  @@distortion = 'low'
  
  def self.add_image_style(name, params = [])
    SimpleCaptcha::ImageHelpers.image_styles.update(name.to_s => params)
  end
  
  def self.setup
    yield self
  end
end

if Rails.env.test?
  SimpleCaptcha::ModelHelpers::InstanceMethods.module_eval do
    undef :is_captcha_valid?
    def is_captcha_valid?; SimpleCaptcha.value; end
  end
  SimpleCaptcha::ControllerHelpers.module_eval do
    undef :simple_captcha_valid?
    def simple_captcha_valid?; SimpleCaptcha.value; end
  end
  ActiveSupport::TestCase.class_eval do
    setup do
      captcha_fail # Fail by default
    end

    def captcha_fail
      SimpleCaptcha.value = false
    end
    def captcha_success
      SimpleCaptcha.value = true
    end
  end
end