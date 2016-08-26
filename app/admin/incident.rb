ActiveAdmin.register Incident do
  menu priority: 1

  permit_params :category_id

  # Don't allow creating incidents, since syncing should be the only way of
  # creating incidents in Retrodot.
  actions :all, except: [:new]

  member_action :sync, method: :post do
    Mediators::Incident::Syncher.run(incident: resource[:incident_id])
    redirect_to resource_path, notice: "Synced!"
  end

  # add a "sync" button to the "view incident" page
  action_item :sync, only: :show do
    link_to 'Sync', sync_admin_incident_path(resource)
  end

  # add a batch action for updating category
  batch_action :categorize, form: ->{{category: Category.pluck(:name, :id)}} do |ids, inputs|
    # inputs is a hash of all the form fields you requested
    ids.each do |id|
      i = Incident.find(id)
      i.category = Category.find(inputs["category"])
      i.save!
    end

    redirect_to collection_path, notice: "Updated category #{ids.length} for incidents!"
  end

  index do
    selectable_column
    column :incident_id
    column :created_at
    column :updated_at
    column :state
    column :duration
    column :title
    column :review
    column :followup_on
    column :category
    actions do |incident|
      link_to 'Sync', sync_admin_incident_path(incident), method: :post
    end
  end
end
