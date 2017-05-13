module DashboardsHelper
  def make_request_link request
    url_for controller: request.class.to_s.tableize, action: :show, id: request.id
  end

  def label_css request
    case request.status
    when Settings.status.block
      "label-danger"
    when Settings.status.pending
      "label-warning"
    when Settings.status.active
      "label-success"
    end
  end

  def link_to_add_fields label, f, association, locals = {}
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for association, new_object, child_index: "new_#{association}" do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to label, "#", onclick: "add_fields(this, \"#{association}\",
      \"#{escape_javascript(fields)}\")", class: locals[:class]
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def link_to_remove_fields_answer(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields_answer(this)")
  end

  def link_to_remove_fields_type(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields_type(this)")
  end

  def link_to_function(name, *args, &block)
    html_options = args.extract_options!.symbolize_keys
    function = block_given? ? update_page(&block) : args[0] || ""
    onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
    href = html_options[:href] || "#"
    content_tag(:a, name, html_options.merge(href: href, onclick: onclick))
  end

  def load_register_course course
    @register_course = course.register_course.present? ? course.register_course : RegisterCourse.new
  end

  def load_time_for_exam lesson
    @time_for_exam = lesson.time_for_exam.present? ? lesson.time_for_exam : TimeForExam.new
  end

  def button_submit_f object
    object.present? ? "Cập nhật" : "Tạo"
  end

  def time_do_exam time
    time.min + (time.hour * 60)
  end
end
