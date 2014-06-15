

#SMTP Settings
SMTP_PORT = ''      # eg,'587'
SMTP_DOMAIN = ''    # eg,'gmail.com'
SMTP_SERVER = ''    # eg,'smtp.gmail.com'
SMTP_USER = ''      # eg 'you@gmail.com'
SMTP_PASSWORD = '', # eg 'popsiclesaretasty'

# Mail settings
MAIL_FROM = '',     # eg 'dev@yourcompany.com'
MAIL_TO = '',       # eg 'dev@yourcompany.com'

def send_outdated_branches_email

    # Dont send an email if we don't have any outdated branches
    if @outdated_branch_messages.size == 0
        puts "Not sending any emails"
        return
    end
    puts "Sending out email about the following:\n" + @outdated_branch_messages.join("\n") if @verbose

    message = "From: Branch Monitor <#{MAIL_FROM}>\n" +
        "To: #{MAIL_TO} <#{MAIL_TO}>\n" +
        "Subject: Branch[es] are 50+ commits behind develop\n" +
        "\n" +
        "Don't be lazy, and fix the following outdated branches: \n" +
        "\t" + @outdated_branch_messages.join("\n\t")

    smtp = Net::SMTP.new SMTP_SERVER, SMTP_PORT
    smtp.enable_starttls

    smtp.start(SMTP_DOMAIN, SMTP_USER, SMTP_PASSWORD, :login) do |started_smtp|
        started_smtp.send_message message, MAIL_FROM, MAIL_TO
    end
end