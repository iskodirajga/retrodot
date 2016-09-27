require 'trello'
require 'google/apis/script_v1'

ActiveAdmin.register Incident do
  config.sort_order = 'incident_id_desc'

  menu priority: 1

  permit_params :category_id

  # Don't allow creating incidents, since syncing should be the only way of
  # creating incidents in Retrodot.
  actions :all, except: [:new]

  # This creates /admin/:incident/sync which is linked to below.
  member_action :sync, method: :post do
    Mediators::Incident::OneSyncher.run(id: resource[:incident_id])
    redirect_to resource_path, notice: "Synced!"
  end

  # /admin/:incident/create_trello_card
  member_action :create_trello_card, method: %i[get post] do
    begin
      Mediators::Incident::CreateCard.run(
        id:                  resource[:incident_id],
        title:               resource[:title],
        trello_oauth_token:  current_user.trello_oauth_token,
        trello_oauth_secret: current_user.trello_oauth_secret
      )
    rescue Trello::InvalidAccessToken, Trello::Error, NoMethodError
      log_error($!, at: :create_trello_card, fn: :member_action)
      session[:return_to] = resource[:incident_id]
      redirect_to "/auth/trello"
    else
      log(at: :create_trello_card, fn: :member_action, incident_id: resource[:incident_id])
      redirect_to collection_path, notice: "Card Successfully Created"
    end
  end

  # /admin/:incident/create_retrospective_doc
  member_action :create_retrospective_doc, method: %i[get post] do
  begin
    @session = Google::Auth::UserRefreshCredentials.new(
      client_id:     Config.google_client_id,
      client_secret: Config.google_client_secret,
      refresh_token: current_user.google_refresh_token,
      code:          current_user.google_auth_code
    )
    postmortem_date = resource[:review] ? resource[:followup_on] : false

    @session.fetch_access_token!

    Mediators::Incident::CreateRetroDoc.run(
        id:              resource[:incident_id],
        auth:            @session,
        title:           resource[:title],
        postmortem_date: postmortem_date
    )
  rescue Signet::AuthorizationError, Google::Apis::AuthorizationError
      log_error($!, at: :create_retrospective_doc, fn: :member_action)
      session[:return_to] = create_retrospective_doc_admin_incident_path(resource[:id])
      redirect_to "/auth/google_oauth2"
    rescue Google::Apis::ClientError => e
      redirect_to collection_path, notice: "Error: #{e}"
    else
      log(at: :create_retrospective_doc, fn: :member_action, incident_id: resource[:incident_id])
      redirect_to collection_path, notice: "Retrospective doc successfully created for Incident: #{resource[:incident_id]}"
    end
  end

  # This creates /admin/:incident/send_email which is posted from javascript triggered by the link below.
  member_action :send_email, method: :post do
    redirect_to collection_path, notice: "PLACEHOLDER: will send email: #{params['inputs']}"
  end

  # add a "sync" button to the "view incident" page
  action_item :sync, only: :show do
    link_to 'Sync', sync_admin_incident_path(resource)
  end

  action_item :create_trello_card, only: :post do
    link_to 'Create Trello Card', create_trello_card_admin_incident_path(resource)
  end

  action_item :create_retrospective_doc, only: :post do
    link_to 'Create Retro Doc', create_retrospective_doc_admin_incident(resource)
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
      item 'Create Trello Card', create_trello_card_admin_incident_path(incident), method: :post, class: 'member_link'
      item 'Create Retro Doc', create_retrospective_doc_admin_incident_path(incident), method: :post, class: 'member_link'

      # This triggers a modal dialog and posts the results back to the
      # :send_email member action above.
      item 'Send Retro Email', '#',
        class: 'retrodot_send_email member_link',
        "data-action"  => send_email_admin_incident_path(incident),
        "data-cc"      => Config.email_cc,
        "data-subject" => "Incident \##{incident.incident_id} retrospective needed",
        "data-body"    => "Dear ___,\n\n[...]\n\nThanks,\n#{controller.current_user.name}",
        "data-inputs"  =>
          { To:      :text,
            CC:      :text,
            Subject: :text,
            Body:    :textarea}.to_json
    end
  end
end
