module ChatOps
  module MessageHelpers
    def unknown_incident_warning
      message 'unknown incident (do you need to "start incident" first?)'
    end

    def old_incident_warning
      message "It looks like you may have forgotten to run `#{Config.chatops_prefix}start incident`.  If you really meant incident #{@incident.incident_id}, please specify the incident id with your command."
    end

    def message(text)
      { message: prevent_highlights(text) }
    end

    # In the future, this might tag with some kind of metadata indicating an
    # error.
    alias_method :error, :message

    def reaction(name)
      { reaction: name }
    end
  end
end
