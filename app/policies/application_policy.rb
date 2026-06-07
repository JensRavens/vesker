# Base Pundit policy. Predicates default to false; subclasses open up the actions
# they allow. Authorization is enforced in controllers via `authorize`, and views
# receive the resolved booleans as props (Phlex components have no Pundit helpers).
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index? = false

  def show? = false

  def create? = false

  def new? = create?

  def update? = false

  def edit? = update?

  def destroy? = false
end
