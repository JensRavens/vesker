# Encapsulates a delivered email so specs assert against a friendly object instead
# of poking at ActionMailer internals. Ported from the flipvinyls project, adapted
# to our Minitest + ActiveJob::TestHelper setup.
class TestMail
  attr_reader :to, :from, :subject, :body

  def initialize(mail)
    @to = mail["to"]
    @from = mail["from"]
    @subject = mail.subject
    @original_body = (mail.html_part || mail.text_part || mail).decoded
    @body = Nokogiri::HTML(@original_body)
  end

  # The visible text of the mail (handy for codes and copy assertions).
  def text
    body.text
  end

  def link_urls
    body.css("a").pluck("href")
  end
end

module MailHelper
  extend ActiveSupport::Concern
  include ActiveJob::TestHelper

  class NoMailSentError < StandardError; end

  included do
    setup { reset_mails }
  end

  def last_mail
    return nil if ActionMailer::Base.deliveries.empty?

    TestMail.new(ActionMailer::Base.deliveries.last)
  end

  def last_mail!
    last_mail || raise(NoMailSentError)
  end

  def reset_mails
    ActionMailer::Base.deliveries = []
  end

  # Run the job queue (where mail is enqueued via deliver_later) until it drains.
  def run_jobs
    count = perform_enqueued_jobs
    run_jobs if count.to_i.positive?
  end
end
