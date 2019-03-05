import hudson.model.*;
import jenkins.model.*;
import hudson.tools.*;
import hudson.util.Secret;

Thread.start {
      sleep 10000
      println "--> setting agent port for jnlp"
      def env = System.getenv()
      int port = env['JENKINS_SLAVE_AGENT_PORT'].toInteger()
      Jenkins.instance.setSlaveAgentPort(port)
      println "--> setting agent port for jnlp... done"
      
      println "--> Setting up SMTP.."
      def SystemAdminMailAddress='notification@ledgerium.net';
      def SMTPUser='notification@ledgerium.net';
      def SMTPPassword='ionic-ken-finite-ajax-degum-byword';
      def SMTPPort = '465';
      def SMTPHost = 'smtp.gmail.com';

      def instance = Jenkins.getInstance()
      def mailServer = instance.getDescriptor("hudson.tasks.Mailer")
      def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()
      def extmailServer = instance.getDescriptor("hudson.plugins.emailext.ExtendedEmailPublisher")
      jenkinsLocationConfiguration.setAdminAddress(SystemAdminMailAddress)
      jenkinsLocationConfiguration.save()
      
      mailServer.setSmtpAuth(SMTPUser, SMTPPassword)
      mailServer.setSmtpHost(SMTPHost)
      mailServer.setSmtpPort(SMTPPort)
      mailServer.setUseSsl(true)
      mailServer.setCharset("UTF-8")

      //Extended-Email
      extmailServer.smtpAuthUsername=SMTPUser
      extmailServer.smtpAuthPassword=Secret.fromString(SMTPPassword)
      extmailServer.smtpHost=SMTPHost
      extmailServer.smtpPort=SMTPPort
      extmailServer.useSsl=true
      extmailServer.charset="UTF-8"

      // Save the state
      instance.save()
}
