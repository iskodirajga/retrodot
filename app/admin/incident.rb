require 'trello'
require 'google/apis/script_v1'

class GoogleAuthRequired < StandardError; end
class TrelloAuthRequired < StandardError; end

ActiveAdmin.register Incident do
  config.sort_order = 'incident_id_desc'

  preserve_default_filters!
  filter :responders, collection: proc { Incident.all.map { |i| i.responders.map(&:name).compact}.flatten.uniq }

  menu priority: 1

  permit_params :category_id

  # Don't allow creating incidents, since syncing should be the only way of
  # creating incidents in Retrodot.
  actions :all, except: [:new]

  action_item :index, only: :index, if: proc{ User.with_slack_token.empty? } do
    link_to 'WARNING: Slack integration setup incomplete!', "/auth/slack_install",  { style: "color: #FF0000" }
  end

  # This creates /admin/:incident/sync which is linked to below.
  member_action :sync, method: :post do
    Mediators::Incident::OneSyncher.run(id: resource[:incident_id])
    redirect_to resource_path, notice: "Synced!"
  end

  member_action :prepare_retro, method: :post do
    begin
      Mediators::Incident::PrepareRetro.run(
        incident:     resource,
        current_user: current_user
      )
    rescue TrelloAuthRequired
      log_error($!, at: :create_trello_card, fn: :member_action)
      session[:return_to] = resource[:id]
      redirect_to "/auth/trello"
    rescue GoogleAuthRequired
        log_error($!, at: :create_retrospective_doc, fn: :member_action)
        session[:return_to] = resource[:id]
        redirect_to "/auth/google_oauth2"
    rescue NoMethodError => e
        redirect_to collection_path, flash: { error: "Error: #{e}" }
    else
      redirect_to collection_path, notice: "Documents for Retrospective '#{resource.title}' have been prepared."
    end
  end

  member_action :send_email, method: :post do
    unless resource.retro_prepared?
      redirect_to collection_path, flash: { error: 'You need to run Prepare Retro First.' }
      return
    end

    email = JSON.parse(params['inputs'])

    NotificationsMailer.retro_followup(
      incident: resource,
      sender:   current_user.email,
      to:       email["To"],
      cc:       email["CC"],
      subject:  email["Subject"]
    ).deliver_now

    redirect_to collection_path, notice: "Retrospective followup sent for Incident: #{resource.incident_id}!"
  end

  # add a "sync" button to the "view incident" page
  action_item :sync, only: :show do
    link_to 'Sync', sync_admin_incident_path(resource)
  end

  action_item :prepare_retro, only: :post do
    link_to 'Prepare Retro Card/Doc', prepare_retro_admin_incident_path(resource)
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
    column :started_at
    column :resolved_at
    column :state
    column :duration
    column :title
    column :review
    column :followup_on
    column :category
    actions do |incident|
      item 'Sync', sync_admin_incident_path(incident), method: :post, class: 'member_link'
      item 'Prepare Retro', prepare_retro_admin_incident_path(incident), method: :post, class: 'member_link'

      # This triggers a modal dialog and posts the results back to the
      # :send_email member action above.
      item 'Send Retro Email', '#',
        class: 'retrodot_send_email member_link',
        "data-action"  => send_email_admin_incident_path(incident),
        "data-cc"      => Config.email_cc,
        "data-subject" => "Incident \##{incident.incident_id} retrospective needed",
        "data-inputs"  =>
          { To:      :text,
            CC:      :text,
            Subject: :text
          }.to_json
    end
  end
end
