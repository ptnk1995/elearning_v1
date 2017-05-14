class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new
    case
    when user.admin?
      admin_permission user
    when user.teacher?
      teacher_permission user
    when user.member?
      member_permission user
    end
  end

  def member_permission user
    can :read, Category
    cannot :manage, TimeForExam
    cannot :manage, RegisterCourse
    can :manage, Post
    can :read, User
    can :update, User, id: user.id
    can :read, UserCourse, user_id: user.id
    can :read, Lesson do |lesson|
      user.course_ids.include?(lesson.course_id) && user.courses.present?
    end
    can [:read, :create, :update], Exam
  end

  def admin_permission user
    can :manage, :all
  end

  def teacher_permission user
    can :read, Category
    can :read, User
    can :update, User, id: user.id
    can :manage, Course, owner_id: user.id
    can :manage, Lesson
    can :manage, Question
    can :manage, TimeForExam
    can :manage, RegisterCourse
    can :manage, UserCourse, user.courses.include?(:course_id)
  end
end

