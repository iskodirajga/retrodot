ActiveAdmin.register Incident do
  menu priority: 1

  permit_params :category_id

  # Don't allow creating incidents, since syncing should be the only way of
  # creating incidents in Retrodot.
  actions :all, except: [:new]

  # This creates /admin/:incident/sync which is linked to below.
  member_action :sync, method: :post do
    Mediators::Incident::Syncher.run(incident: resource[:incident_id])
    redirect_to resource_path, notice: "Synced!"
  end

  # This creates /admin/:incident/send_email which is posted from javascript triggered by the link below.
  member_action :send_email, method: :post do
    redirect_to collection_path, notice: "PLACEHOLDER: will send email: #{params['inputs']}"
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
      item 'Sync', sync_admin_incident_path(incident), method: :post, class: 'member_link'

      # This triggers a modal dialog and posts the results back to the
      # :send_email member action above.
      item 'Send Retro Email', '#',
        class: 'retrodot_send_email member_link',
        "data-action" => send_email_admin_incident_path(incident),
        "data-cc" => Config.email_cc,
        "data-subject" => "Incident \##{incident.incident_id} retrospective needed",
        "data-body" => "Dear ___,\n\n[...]\n\nThanks,\n#{controller.current_user.name}",
        "data-inputs" =>
          { To:      :text,
            CC:      :text,
            Subject: :text,
            Body:    :textarea}.to_json
    end
  end
end
