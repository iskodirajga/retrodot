ActiveAdmin.register Incident do
  menu priority: 1

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

  index do
    column :incident_id
    column :created_at
    column :updated_at
    column :state
    column :duration
    column :title
    column :requires_followup
    column :followup_on
    actions do |incident|
      link_to 'Sync', sync_admin_incident_path(incident), method: :post
    end
  end
end
