module LayoutHelper
  def title(value = nil)
    @layout_title ||= 'Internet Switcher'
    @layout_title = value if value
    @layout_title
  end

  def body_class
    classes = []
    classes << "#{current_layout}-layout".dasherize
    classes << controller.class.name.underscore.dasherize.gsub('/', '-').dasherize
    classes << "#{controller.action_name}-action".dasherize
    classes.join(' ')
  end

  def current_layout
    layout = controller.send(:_layout, lookup_context, formats)
    if layout.instance_of? String
      layout
    else
      layout.virtual_path.split('/')[1..-1].join('-')
    end
  end
end
