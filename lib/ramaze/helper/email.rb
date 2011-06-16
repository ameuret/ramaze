require 'net/smtp'

module Ramaze
  module Helper
    ##
    # The Email helper can be used as a simple way of sending Emails from your
    # application. In order to use this helper you first need to load it:
    #
    #  class Comments < Ramaze::Controller
    #    helper :email
    #  end
    #
    # Sending an Email can be done by calling the method send_email():
    #
    #  send_email('info@yorickpeterse.com', 'Hello, world!', 'Hello, this is an Email')
    #
    # Ramaze will log any errors in case the Email could not be sent so you don't have to
    # worry about this.
    #
    # == Options
    #
    # This module can be configured using Innate::Optioned. Say you want to change the
    # SMTP host you simply need to do the following:
    #
    #  Ramaze::Helper::Email.options.host = 'mail.google.com'
    #
    # Various other options are available, for a full list of these options run the
    # following in an IRB session:
    #
    #  puts Ramaze::Helper::Email.options
    #
    # By default this helper uses \r\n for newlines, this can be changed as following:
    #
    #  Ramaze::Helper::Email.options.newline = "\n"
    #
    # It's important that this setting matches the settings of your SMTP server as
    # otherwise you (usually) won't be able to send any Emails.
    #
    # @author Yorick Peterse
    # @author Michael Fellinger
    # @since  16-06-2011
    #
    module Email
      include Innate::Optioned

      options.dsl do
        o 'The SMTP server to use for sending Emails'     , :host          , nil
        o 'The SMTP helo domain'                          , :helo_domain   , nil
        o 'The username for the SMTP server'              , :username      , nil
        o 'The password for the SMTP server'              , :password      , nil
        o 'The sender\'s Email address'                   , :sender        , nil
        o 'The port of the SMTP server'                   , :port          , 25
        o 'The authentication type of the SMTP server'    , :auth_type     , :login
        o 'An array of addresses to forward the Emails to', :bcc           , []
        o 'The name (including the Email) of the sender'  , :sender_full   , nil
        o 'A prefix to use for the subjects of the Emails', :subject_prefix, nil
        o 'The type of newlines to use for the Email'     , :newline       , "\r\n"
        o 'The generator to use for Email IDs'            , :generator     , lambda do
          "<" + Time.now.to_i.to_s + "@" + Ramaze::Helper::Email.options.helo_domain + ">"
        end
      end
      
      ##
      # Sends an Email over SMTP.
      #
      # @example
      #  send_email('info@yorickpeterse.com', 'Hello, world!', 'Hello, this is an Email')
      #
      # @author Yorick Peterse
      # @author Michael Fellinger
      # @since  16-06-2011
      # @param  [String] recipient The Email address to send the Email to.
      # @param  [String] subject The subject of the Email.
      # @param  [String] message The body of the Email
      #
      def send_email(recipient, subject, message)
        sender  = options.sender_full || "#{options.sender} <#{options.sender}>"
        subject = [options.subject_prefix, subject].join(' ').strip
        id      = options.generator.call

        # Generate the body of the Email
        email   = [
          "From: #{sender}", "To: <#{recipient}>", "Date: #{Time.now.rfc2822}",
          "Subject: #{subject}", "Message-Id: #{id}", '', message
        ].join(options.newline)

        # Send the Email
        email_options = []

        [:host, :port, :helo_domain, :username, :password, :auth_type].each do |k|
          email_options.push(options[k])
        end

        begin
          Net::SMTP.start(*email_options) do |smtp|
            smtp.send_message(email, options.sender, [recipient, *options.bcc])
            Ramaze::Log.info("Email sent to #{recipient} with subject \"#{subject}\"")
          end
        rescue => e
          Ramaze::Log.error("Failed to send an Email to #{recipient}: #{e.inspect}")
        end
      end
    end # Email
  end # Helper
end # Ramaze
