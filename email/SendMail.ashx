<%@ WebHandler Language="C#" Class="SendMail" %>

using System;
using System.Web;

public class SendMail : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        string method = context.Request["Method"];
        string name = context.Request["name"];
        string space = context.Request["space"];
        string tel = context.Request["tel"];
        string mail = context.Request["mail"];
        string message = context.Request["message"];
        if ("Send".Equals(method))
        {
            Send(name, space, tel, mail, message);
        }
        else if ("SendQQ".Equals(method))
        {
            SendQQ(name, space, tel, mail, message);
        }
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }
    /// <summary>
    /// 使用163邮箱发送邮件（会被当成垃圾邮件而发送不出去）
    /// </summary>
    /// <param name="name"></param>
    /// <param name="space"></param>
    /// <param name="tel"></param>
    /// <param name="mail"></param>
    /// <param name="message"></param>
    /// <returns></returns>
    public string Send(string name, string space, string tel, string mail, string message)
    {
        try
        {
            System.Configuration.Configuration config = System.Web.Configuration.WebConfigurationManager.OpenWebConfiguration("~/");
            System.Net.Configuration.MailSettingsSectionGroup mailSettings = System.Net.Configuration.NetSectionGroup.GetSectionGroup(config).MailSettings;
            System.Text.StringBuilder body = new System.Text.StringBuilder();
            body.AppendFormat("您的真实姓名：{0}", name)
                .AppendLine()
                .AppendFormat("出版社名称：{0}", space)
                .AppendLine()
                .AppendFormat("联系电话：{0}", tel)
                .AppendLine()
                .AppendFormat("邮箱：{0}", mail)
                .AppendLine()
                .AppendFormat("留言：{0}", message);
            SendSmtpMail.EmailSettings email = new SendSmtpMail.EmailSettings();
            email.serverName = mailSettings.Smtp.Network.Host;
            email.serverPort = mailSettings.Smtp.Network.Port;
            email.mailFromAdress = mailSettings.Smtp.From;
            email.username = mailSettings.Smtp.Network.UserName;
            email.password = mailSettings.Smtp.Network.Password;//此处为客户端验证密码
            email.mailToAddress = mailSettings.Smtp.From;
            SendSmtpMail.SendMail send = new SendSmtpMail.SendMail(email);
            send.sendSmtpMail(body.ToString(), "易得调研", false);
            return "{\"success\":true,\"message\":\" \"}";
        }
        catch (Exception ex)
        {
            return "{\"success\":false,\"message\":\"" + ex.Message + "\"}";
        }
    }
    /// <summary>
    /// 使用QQ邮箱发送邮件
    /// </summary>
    /// <param name="name"></param>
    /// <param name="space"></param>
    /// <param name="tel"></param>
    /// <param name="mail"></param>
    /// <param name="message"></param>
    /// <returns></returns>
    public string SendQQ(string name, string space, string tel, string mail, string message)
    {
        try
        {
            string from = System.Configuration.ConfigurationManager.AppSettings["FromMail"].ToString();
            string client = System.Configuration.ConfigurationManager.AppSettings["ClientWord"].ToString();
            string to = System.Configuration.ConfigurationManager.AppSettings["ToMail"].ToString();
            System.Text.StringBuilder body = new System.Text.StringBuilder();
            body.AppendFormat("<div><p>您的真实姓名：{0}</p>", name)
                .AppendFormat("<p>出版社名称：{0}</p>", space)
                .AppendFormat("<p>联系电话：{0}</p>", tel)
                .AppendFormat("<p>邮箱：{0}</p>", mail)
                .AppendFormat("<p>留言：{0}</p></div>", message);
            System.Net.Mail.SmtpClient smtpClient = new System.Net.Mail.SmtpClient();
            //QQ邮件必须先设置SSL==>UseDefaultCredentials=false===>Credentials
            smtpClient.EnableSsl = true;//SSL链接

            smtpClient.UseDefaultCredentials = false;

            smtpClient.DeliveryMethod = System.Net.Mail.SmtpDeliveryMethod.Network;//指定电子邮件发送方式        

            smtpClient.Host = "smtp.qq.com"; //指定SMTP服务器        

            smtpClient.Credentials = new System.Net.NetworkCredential(from, client);//用户名和授权码
            // 发送邮件设置        
            System.Net.Mail.MailMessage mailMessage = new System.Net.Mail.MailMessage(from, to); // 发送人和收件人        

            mailMessage.Subject = "易得调研";//主题        

            mailMessage.Body = body.ToString();

            mailMessage.BodyEncoding = System.Text.Encoding.UTF8;//正文编码        

            mailMessage.IsBodyHtml = true;//设置为HTML格式        

            mailMessage.Priority = System.Net.Mail.MailPriority.Normal;//优先级

            smtpClient.Send(mailMessage);
            return "{\"success\":true,\"message\":\" \"}";
        }
        catch (Exception ex)
        {
            return "{\"success\":false,\"message\":\"" + ex.Message + "\"}";
        }
    }
}