require "csv"
class ChildrenController < ApplicationController
  before_action :authenticate_user!

  def index
    @children = current_partner.children
                               .includes(:family)
                               .order(active: :desc, last_name: :asc)
                               .class_filter(filter_params)

    respond_to do |format|
      format.html
      format.csv do
        render(csv: @children.map(&:to_csv))
      end
    end
    @family = @children.collect(&:family).compact.uniq.sort
    @selected_family = filter_params[:from_family]
    @selected_children_first_name = filter_params[:from_children]
  end

  def show
    @child = current_partner.children.find_by(id: params[:id])
    @child_item_requests = @child
                           .child_item_requests
                           .includes(:item_request)
  end

  def new
    @child = family.children.new
  end

  def active
    child = current_partner.children.find(params[:child_id])
    child.active = !child.active
    child.save
  end

  def edit
    @child = current_partner.children.find_by(id: params[:id])
  end

  def create
    child = family.children.new(child_params)

    if child.save
      redirect_to child, notice: "Child was successfully created."
    else
      render :new
    end
  end

  def update
    child = current_partner.children.find_by(id: params[:id])

    if child.update(child_params)
      redirect_to child, notice: "Child was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    child = current_partner.children.find_by(id: params[:id])
    if child.present?
      child.destroy
      redirect_to children_url, notice: "Child was successfully destroyed."
    end
  end

  private

  def family
    @_family ||= current_partner.families.find_by(id: params[:family_id])
  end

  def child_params
    params.require(:child).permit(
      :active,
      :agency_child_id,
      :comments,
      :date_of_birth,
      :first_name,
      :gender,
      :health_insurance,
      :item_needed_diaperid,
      :last_name,
      :race,
      :archived,
      child_lives_with: []
    )
  end

  def filter_params
    return {} unless params.key?(:filters)

    params.require(:filters).slice(:from_family, :from_children)
  end
end
