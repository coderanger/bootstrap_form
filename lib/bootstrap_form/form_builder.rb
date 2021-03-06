module BootstrapForm
  class FormBuilder < ActionView::Helpers::FormBuilder
    delegate :content_tag, to: :@template

    def initialize(object_name, object, template, options, proc)
      super
      @help_style = options.fetch(:help, :inline)
    end

    %w{text_field text_area password_field collection_select file_field date_select select}.each do |method_name|
      define_method(method_name) do |name, *args, &block|
        options = args.extract_options!.symbolize_keys!
        content_tag :div, class: "control-group#{(' error' if object.errors[name].any?)}"  do
          label(name, options[:label], class: 'control-label') +
          content_tag(:div, class: 'controls') do
            help = object.errors[name].any? ? object.errors[name].join(', ') : options[:help]
            help_tag, help_css = if options.fetch(:help_style, @help_style).to_sym == :block
              [:p, 'help-block']
            else
              [:span, 'help-inline']
            end
            if help || block
              help = content_tag(help_tag, class: help_css) do
                content = ''
                content << ERB::Util.html_escape(help) if help
                content << content_tag('span', class: 'extra', &block) if block
                content.html_safe
              end
            end
            args << options.except(:label, :help)
            super(name, *args) + help
          end
        end
      end
    end

    def check_box(name, *args)
      options = args.extract_options!.symbolize_keys!
      content_tag :div, class: "control-group#{(' error' if object.errors[name].any?)}"  do
        content_tag(:div, class: 'controls') do
          args << options.except(:label, :help)
          html = super(name, *args) + ' ' + options[:label]
          label(name, html, class: 'checkbox')
        end
      end
    end

    def actions(&block)
      content_tag :div, class: "form-actions" do
        block.call
      end
    end

    def primary(name, options = {})
      options.merge! class: 'btn btn-primary'

      submit name, options
    end

    def alert_message(title, *args)
      options = args.extract_options!
      css = options[:class] || "alert alert-error"

      if object.errors.full_messages.any?
        content_tag :div, class: css do
          title
        end
      end
    end
  end
end
