require "opentok"

class Admins::SetStatusCoursesController < DashboardController
  before_action :authenticate_admin!

  def index
    course = Course.find_by id: params[:id]
    if course.present?
      if course.update status: params[:status].to_i, approver_id: current_user.id
        create_activity Course.name, course, "register_course.create"
        create_notification_for_member Course.name, course, "#{course.status}.#{Course.name}", course.owner_id
        # if course.active?
        #   create_room course
        # end
      else
        flash[:errors] = "Cập nhật khóa học không thành công"
      end
    else
      flash[:errors] = "Không tìm thấy khóa học"
    end
    redirect_to admins_courses_path
  end

  private

  def config_opentok
    if @opentok.nil?
     @opentok = OpenTok::OpenTok.new(ENV["KEY_OPENTOK"], ENV["TOKEN"])
    end
  end

  def create_room course
    config_opentok
    session =  @opentok.create_session
    # session = @opentok.create_session :media_mode => :routed
    @room = Room.create owner_id: course.owner.id, course_id: course.id,
      name: course.name, session_id: session.session_id, status: 0
    if @room.blank?
      course.update status: 2
      flash[:errors] = "Tạo phòng không thành công"
    else
      UserNotifierMailer.send_email_after_approver(course.owner).deliver_later
      flash[:success] = "Tạo phòng thành công"
    end
  end

  def create_activity_accept_course course, message
    create_activity Course.name, course, message
  end
end
