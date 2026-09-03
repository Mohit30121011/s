package com.nlogistic.util;

import java.io.InputStream;
import java.util.Properties;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class EmailService {

    private static Properties mailProps = new Properties();

    static {
        loadConfig();
    }

    public static void loadConfig() {
        try (InputStream is = EmailService.class.getClassLoader().getResourceAsStream("mail.properties")) {
            if (is != null) {
                mailProps.load(is);
            }
        } catch (Exception e) {
            System.err.println("Could not load mail.properties: " + e.getMessage());
        }
    }

    public static boolean sendPasswordResetEmail(String toEmail, String username, String resetLink) {
        final String host = mailProps.getProperty("mail.smtp.host", "smtp.gmail.com");
        final String port = mailProps.getProperty("mail.smtp.port", "587");
        final String usernameSmtp = mailProps.getProperty("mail.smtp.username", "");
        final String passwordSmtp = mailProps.getProperty("mail.smtp.password", "").replaceAll("\\s+", "");
        final String fromEmail = mailProps.getProperty("mail.from.email", usernameSmtp);
        final String fromName = mailProps.getProperty("mail.from.name", "NLogistic Enterprise");

        if (usernameSmtp.isEmpty() || passwordSmtp.isEmpty()) {
            System.err.println("SMTP credentials missing in mail.properties. Link is: " + resetLink);
            return false;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", port);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.ssl.trust", host);

        try {
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(usernameSmtp, passwordSmtp);
                }
            });

            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail, fromName));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Security Notification: Password Reset Request for " + username, "UTF-8");

            String htmlContent = "<div style=\"font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 560px; margin: 0 auto; background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.06);\">"
                    + "<div style=\"background: #0F172A; padding: 28px 32px; border-bottom: 3px solid #FC8019;\">"
                    + "  <div style=\"display: flex; align-items: center; gap: 10px;\">"
                    + "    <h2 style=\"color: #FFFFFF; font-size: 22px; font-weight: 800; margin: 0; letter-spacing: -0.5px;\">N<span style=\"color: #FC8019;\">Logistic</span> Enterprise</h2>"
                    + "  </div>"
                    + "  <p style=\"color: #94A3B8; font-size: 13px; margin: 6px 0 0;\">RBAC & Identity Access Management System</p>"
                    + "</div>"
                    + "<div style=\"padding: 32px;\">"
                    + "  <h3 style=\"color: #0F172A; font-size: 18px; font-weight: 700; margin-top: 0;\">Password Reset Request</h3>"
                    + "  <p style=\"color: #475569; font-size: 14px; line-height: 1.6; margin-bottom: 24px;\">Hello <strong>" + username + "</strong>,</p>"
                    + "  <p style=\"color: #475569; font-size: 14px; line-height: 1.6; margin-bottom: 24px;\">An administrator has initiated a password reset for your staff account. Click the button below to configure your new secure password:</p>"
                    + "  <div style=\"text-align: center; margin: 32px 0;\">"
                    + "    <a href=\"" + resetLink + "\" style=\"display: inline-block; background: #FC8019; color: #FFFFFF; text-decoration: none; padding: 14px 32px; border-radius: 50px; font-size: 14px; font-weight: 700; box-shadow: 0 4px 14px rgba(252, 128, 25, 0.4);\">Reset My Password &rarr;</a>"
                    + "  </div>"
                    + "  <p style=\"color: #64748B; font-size: 12.5px; line-height: 1.5; background: #FFF3EA; border-left: 4px solid #FC8019; padding: 12px 16px; border-radius: 6px;\">"
                    + "    <strong>Note:</strong> This one-time link is valid for <strong>15 minutes</strong>. If you did not request this, please contact your system administrator immediately."
                    + "  </p>"
                    + "  <p style=\"color: #94A3B8; font-size: 12px; margin-top: 24px; word-break: break-all;\">"
                    + "    If the button does not work, copy and paste this link in your browser:<br>"
                    + "    <a href=\"" + resetLink + "\" style=\"color: #FC8019;\">" + resetLink + "</a>"
                    + "  </p>"
                    + "</div>"
                    + "<div style=\"background: #F8FAFC; padding: 16px 32px; border-top: 1px solid #E2E8F0; text-align: center; font-size: 11.5px; color: #94A3B8;\">"
                    + "  &copy; 2026 NLogistic Enterprise Freight &amp; Maritime Logistics. All rights reserved."
                    + "</div>"
                    + "</div>";

            message.setContent(htmlContent, "text/html; charset=utf-8");
            Transport.send(message);
            System.out.println(">>> Real Password Reset Email sent successfully to: " + toEmail);
            return true;
        } catch (Exception e) {
            System.err.println("Failed to send real email to " + toEmail + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
