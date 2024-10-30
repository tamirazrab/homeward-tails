require "csv"

module Organizations
  module Importers
    class GoogleCsvImportService
      Status = Data.define(:success?, :count, :no_match, :errors)
      def initialize(file)
        @file = file
        @organization = Current.organization
        @count = 0
        @no_match = []
        @errors = []
      end

      def call
        row_num = 1
        CSV.foreach(@file.to_path, headers: true, skip_blanks: true) do |row|
          row_num += 1
          # Using Google Form headers
          email = row["Email"].downcase
          csv_timestamp = Time.parse(row["Timestamp"])

          person = Person.find_by(email:, organization: @organization)
          previous = FormSubmission.where(person:, csv_timestamp:)

          if person.nil?
            @no_match << [row_num, email]
          elsif previous.present?
            next
          else
            latest_form_submission = person.latest_form_submission
            ActiveRecord::Base.transaction do
              # This checks for the empty form submission that is added when a person is created
              if latest_form_submission.csv_timestamp.nil? && latest_form_submission.form_answers.empty?
                latest_form_submission.update!(csv_timestamp:)
                create_form_answers(latest_form_submission, row)
              else
                create_form_answers(FormSubmission.create!(person:, csv_timestamp:), row)
              end
              @count += 1
            end
          end
        rescue => e
          @errors << [row_num, e]
        end
        Status.new(@errors.empty?, @count, @no_match, @errors)
      end

      private

      def create_form_answers(form_submission, row)
        row.each do |col|
          next if col[0] == "Email" || col[0] == "Timestamp"

          answer = col[1].nil? ? "" : col[1]
          FormAnswer.create!(
            form_submission:,
            question_snapshot: col[0],
            value: answer
          )
        end
      end
    end
  end
end
