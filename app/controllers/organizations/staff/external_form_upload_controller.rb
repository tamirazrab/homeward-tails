module Organizations
  module Staff
    class ExternalFormUploadController < Organizations::BaseController
      layout "dashboard"

      def index
        authorize! :external_form_upload, context: {organization: Current.organization}
      end

      def create
        authorize! :external_form_upload, context: {organization: Current.organization}

        file = params[:files]
        # Only processes single file upload
        import = Organizations::Importers::GoogleCsvImportService.new(file).call

        if import.success?
          # do something
        else
          # import.errors
        end
      end
    end
  end
end
