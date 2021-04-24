$InformationPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'
$subject = "Today's Free Packt eBook"
$modulesToImport = '/root/PSModules/PSToolbox'
$uri = 'https://www.packtpub.com/free-learning'
$discordBotLogo = 'https://freeiconshop.com/wp-content/uploads/edd/book-open-flat.png'
$botName = 'Study Bot'

Import-Module $modulesToImport
$encryptedWebhookUri = Import-Clixml "$PSScriptRoot/EncryptedCredentials/StudyBotDiscordWebhook.clixml"
$plaintextWebhookUri = $encryptedWebhookUri | ConvertFrom-SecureString
$request = Invoke-WebRequest $uri
$eBook = $request.Content | Remove-HtmlTags | Select-String '^Free.eBook.*'

$discordBody = @"
**__Today's Free Packt E-Book:__**
*This e-book must be read using the publisher's online reader, no downloads*

**Link:** $uri
**Title:** $ebook
"@

& "$PSScriptRoot/Send-DiscordWebhook.ps1" -webhook_uri $plaintextWebhookUri -username $botName -content $discordBody -avatar_url $discordBotLogo
