#Requires -RunAsAdministrator

<#
   .SYNOPSIS
      Windows 10-11 Untrasher

   .DESCRIPTION
      The purpose of this script is to remove bloatware from your Windows 10 or 11 machine.
      You have to run this script as administrator and execution policy must be set to unrestricted.
      If you want to keep some of the bloatware edit this script and comment the line.

   .PARAMETER Silent
      The Script will not return anything to the console.

   .PARAMETER NoRestart
      The machine does not restart after the script is done.

   .NOTES
      Version 1

      Author Knuspertrix with help from jhochwald

   .LINK
      https://github.com/Knuspertrixtxt

   .LINK
      https://github.com/jhochwald
#>

# The Parameters
[CmdletBinding(ConfirmImpact = 'Low')]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [switch] $Silent,
   [switch] $NoRestart
)

begin
{

   #region User Check List
   if (-not ($Silent))
   {
      # Remember the user to check everything important before start :)
      Write-Output -InputObject ('Hello ' + $env:USERNAME + '! Welcome to Win10-11_Untrasher V.1')
      Write-Output -InputObject ('You are running this script on the machine : ' +  $env:COMPUTERNAME)
      Write-Output -InputObject '________________________________________________________________________________________________'
      Write-Output -InputObject 'Please check if you have configured the bloatware lists correctly ! '
      # A little Spongebob reference :)
      Read-Host -Prompt 'Are you Ready (kids)? (Press Enter)'
      Write-Output -InputObject ''
      Write-Output -InputObject 'Aye Aye Captain'
      Write-Output -InputObject '________________________________________________________________________________________________'
   }
   #endregion User Check List
}

process
{
   #region APPList
   # List of the bloatware that should be removed
   $AppLS = $null

   $AppLS = @(
      # Windows stuff
      '*Cortana*',                                      # Cortana
      '*Microsoft.549981C3F5F10*',                      # Cortana
      #'*Xbox*',                                         # All Xbox stuff
      #'*StickyNotes*',                                  # StickyNotes
      '*MixedReality*',                                 # Mixed Reality
      '*FeedbackHub*',                                  # Feed-BackHub
      '*Office*',                                       # Office
      '*Bing*',                                         # The Weather APP
      '*Skype*',                                        # Skype
      '*Paint*',                                        # Paint and Paint 3D
      '*Solitaire*',                                    # Solitaire Collection
      '*3D*',                                           # 3D-Viewer
      '*YourPhone*',                                    # YourPhone
      '*Getstarted*',                                   # Get started with Windows
      '*Maps*',                                         # Maps
      '*SoundRecorder*',                                # SoundRecorder
      '*Wallet*',                                       # Wallet
      '*GetHelp*',                                      # GetHelp
      #'*zune*',                                         # Grove Music and the stock Windows video player
      '*people*',                                       # Windows contact app
      #'*Alarm*',                                        # Windows Alarm and Clock APP
      '*Camera*',                                       # Camera APP
      '*ScreenSketch*',                                 # Windows Ink
      #'*Store*',                                        # Windows Store
      #'*Calculator*',                                   # Calculator
      #'*Photos*',                                       # Photos
      '*windowscommunicationsapps*',                    # Mail and calendar
      '*Messaging*',                                    # Message app
      '*Whiteboard*',                                   # Whiteboard
      '*OneConnect*',                                   # Mobile Plans
      '*PowerAutomate*',                                # Power Automate
      '*GamingApp*',                                    # GamingApp
      '*Todos*',                                        # Microsoft To Do
      '*Notepad*',                                      # Notepad
      '*WhatsNew*',                                     # Whats New
      '*MicrosoftTeams*',                               # Teams

      # Bloat that's not from Microsoft
      '*Netflix*',                                      # Netflix
      '*AmazonVideo*',                                  # Amazon Prime Video
      '*AmazonAlexa*',                                  # Amazon Alexa
      '*McAfeeSecurity*',                               # McAfee
      '*Spotify*',                                      # Spotify
      '*Disney*',                                       # Disney
      '*xing*',                                         # Xing
      '*ClipChamp*',                                    # ClipChamp
      '*HiddenCityMysteryofShadows*',                   # Hidden City
      '*Roblox*',                                       # Roblox (Ooof)
      '*Minecraft*',                                    # Minecraft
      '*TikTok*',                                       # TikTok
      '*Tile*',                                         # Tile
      '*BangolufsenAudioControl*',                      # Bang and Olufsen Audio Control
      '*Dropbox*',                                      # Dropbox
      '*NVIDIAControlPanel*',                           # NVIDIA Control Panel

      # Intel
      '*Optane*',                                       # Intel Optane Memory and Storage Management
      '*IntelManagement*',                              # Intel Management and Security Status
      '*IntelGraphicsExperience*',                      # Intel Graphics Controlcenter
      '*ThunderboltControlCenter*',                     # Thunderbolt Control Center

      # HP
      '*HPEasyClean*',                                  # HP Easy Clean
      '*HPPCHardwareDiagnostics*',                      # HP PCHardwareDiagnostics
      '*HPPowerManager*',                               # HP Power manager
      '*HPPrivacySettings*',                            # HP PrivacySettings
      '*HPProgrammableKey*',                            # HP ProgrammableKey
      '*HPQuickDrop*',                                  # HP QuickDrop
      '*HPSupportAssistant*',                           # HP SupportAssistant
      '*HPSystemInformation*',                          # HP SystemInformation
      '*HPAudioControl*',                               # HP AudioControl
      '*HPSystemEventUtility*',                         # HP System EventUtility
      '*HPThermalControl*',                             # HP ThermalControl
      '*HPPrinterControl*',                             # HP PrinterControl
      '*HPInc.EnergyStar*',                             # Energy Star
      '*HPEnhance*',                                    # HP Enhance
      '*HPWorkWell*',                                   # HP Work Well
      '*myHP*'                                          # myHP
   )
   #endregion APPlist

   #region ProgramList
   # List of all Bloatware thats installed as MSI Package
   $ProgramList = @(
      # Microsoft
      '*365*',                                          # Office 365
      '*Office*',                                       # Office

      # HP
      '*HP Client Security Manager*',                   # HP Client Security Manager
      '*HP Notifications*',                             # HP Notifications
      '*HP Security Update Service*',                   # HP Security Update Service
      '*HP Audio Switch*',                              # HP Audio Switch
      '*HP Wolf Security*'                              # HP Wolf Security
   )
   #endregion ProgramList

   #region Stopping Services
   # Stops background services from the Programs in $APPls
   $item = $null

   foreach ($item in $AppLS)
   {
      # Stopping services from the programs that we want to remove
      $services = $null
      $services = (Get-Service -ErrorAction SilentlyContinue | Where-Object DisplayName -Like $item)

      $service = $null
      foreach ($service in $services)
      {
         try
         {
            $CommandReturn = $null
            $CommandReturn = (Stop-Service $service -ErrorAction SilentlyContinue -Confirm:$false)
            if ($Silent)
            {
               # Silence is golden
               $CommandReturn = $null
            }
            else
            {
               # The eye eats with
               Write-Output -InputObject ('Stopping Service: ' + $service.Name + '...')
               # Dump to the Terminal
               $CommandReturn
            }
         }
         catch
         {
            if (-not ($Silent))
            {
               # Drops a little errormessage
               Write-Output -InputObject ('Can not stop service: '+ $services.Name + ' / ' + $services.DisplayName)
            }
         }
         $CommandReturn = $null
      }
      # Clearing of used variables
      $service = $null
      $CommandReturn = $null
   }
   # Clearing of used variables
   $service = $null
   $CommandReturn = $null
   $services = $null
   #endregion Stopping Services

   #region removing Packages
   # Seperator

   $item = $null
   foreach ($item in $AppLS)
   {
      #region removing AppxPackages
      # Removing the AppxPackages
      $packs = $null
      $packs = (Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue | Where-Object Name -Like $item)

      $pack = $null
      foreach ($pack in $packs)
      {
         try
         {
            $CommandReturn = $null
            $CommandReturn = (Remove-AppxPackage -Package $pack -AllUsers -ErrorAction SilentlyContinue -Confirm:$false)
            if ($Silent)
            {
               # Silence is golden
               $CommandReturn = $null
            }
            else
            {
               # The eye eats with
               Write-Output -InputObject ('Removing AppxPackage: ' + $pack.Name + '...')
               # Dump to the Terminal
               $CommandReturn
            }
         }
         catch
         {
            if (-not ($Silent))
            {
               # Drops a little errormessage
               Write-Output -InputObject ('Can not remove AppxPackage: ' + $pack.Name + '/' + $pack.PackageFamilyName)
            }
         }
         # Clearing of used variables
         $pack = $null
         $CommandReturn = $null
      }
      #endregion removing AppxPackages

      #region removing AppxProvisionedPackages
      # Removing the  AppxProvisionedPackages
      $packs = $null
      $packs = (Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object PackageName -Like $item)

      $pack = $null
      foreach ($pack in $packs)
      {
         try {
            $CommandReturn = $null
            $CommandReturn = (Remove-AppxProvisionedPackage -Online -PackageName $pack.PackageName -ErrorAction SilentlyContinue)
            if ($Silent)
            {
               # Silence is golden
               $CommandReturn = $null
            }
            else
            {
               # The eye eats with
               Write-Output -InputObject ('Removing AppxProvisionedPackage: ' + $pack.Displayname + '...')
               # Dump to the Terminal
               $CommandReturn
            }
         }
         catch {
            if (-not ($Silent))
            {
               # Drops a little errormessage
               Write-Output -InputObject ('Can not remove AppxProvisionedPackage: ' + $pack.DisplayName + '/' + $pack.PackageName)
            }
         }
         $CommandReturn = $null
      }
      #endregion removing AppxProvisionedPackages

      # Clearing of used variables
      $pack = $null
      $item = $null
   }
   $packs = $null
   #endregion removing Packages

   #region uninstall

   # Removing the Preinstalled Programms
   $item = $null
   foreach ($item in $ProgramList)
   {
      $packs = $null
      $packs = (Get-Package -ErrorAction SilentlyContinue | Where-Object Name -Like $item | Uninstall-Package -Scope AllUsers -Force -ErrorAction SilentlyContinue)

      $pack = $null
      foreach ($pack in $packs)
      {
         try
         {
            $CommandReturn = (Uninstall-Package $pack -Scope AllUsers -Force -ErrorAction SilentlyContinue -Confirm:$false)
            if ($Silent)
            {
               # Silence is golden
               $CommandReturn = $null
            }
            else
            {
               # The eye eats with
               Write-Output -InputObject ('Uninstalling: ' + $pack.Name + '...')
               # Dump to the Terminal
               $CommandReturn
            }
            $CommandReturn = $null
         }
         catch
         {
            if(-not($Silent))
            {
               # Drops a little errormessage
               (Write-Output -InputObject 'Can not uninstall package: ' + $pack.Name)
            }
         }
      }
      # Clearing of used variables
      $pack = $null
      $CommandReturn = $null
   }
   # Clearing of used variables
   $packs = $null
   $pack = $null
   $CommandReturn = $null
   #endregion uninstall

   #region extra sausages
   # Remove HP Documentation
   if (Test-Path -Path ($env:ProgramW6432 + '\HP\Documentation\Doc_uninstall.cmd') -ErrorAction SilentlyContinue)
   {
      try
      {
         $CommandReturn = $null
         $CommandReturn = Start-Process -FilePath ($env:ProgramW6432 + '\HP\Documentation\Doc_uninstall.cmd') -WindowStyle Hidden
         if ($Silent)
         {
            # Silence is golden
            $CommandReturn = $null
         }
         else
         {
            # Dump to the Terminal
            $CommandReturn
         }
      }
      catch
      {
         if (-not ($Silent))
         {
            # Drops a little errormessage
            Write-Output -InputObject 'Can not find HP Documentation'
         }
      }
      # Clearing of used variables
      $CommandReturn = $null
   }

   # Remove Test Adobe
   if (Test-Path -Path (${env:ProgramFiles(x86)} + '\Online Services\Adobe') -ErrorAction SilentlyContinue)
   {
      try
      {
         $CommandReturn = $null
         $CommandReturn = Remove-Item -Path (${env:ProgramFiles(x86)} + '\Online Services\Adobe') -Force -Recurse -ErrorAction SilentlyContinue
         if ($Silent)
         {
            # Silence is golden
            $CommandReturn = $null
         }
         else
         {
            # Dump to the Terminal
            $CommandReturn
         }
      }
      catch
      {
         if (-not ($Silent))
         {
            Write-Output -InputObject 'Can not find Test Adobe'
         }
      }
      # Clearing of used variables
      $CommandReturn = $null
   }
   #endregion extra sausages
}

end
{
   #region Done Message
   if (-not ($Silent))
   {
      # Telling the user that the Script is finished and that the computer must be restarted
      Write-Output -InputObject '________________________________________________________________________________________________'
      Write-Output -InputObject 'The script is finished'
      if (-not ($NoRestart))
      {
         Write-Output -InputObject 'Your machine restarts in 10 sec.'
      }
      Write-Output -InputObject 'Dont forget to change your execution policy (Windows standard is Restricted) '
      Write-Output -InputObject '________________________________________________________________________________________________'

      Start-Sleep -Seconds 10
   }
   #endregion Done Message

   #region clean up
   # Clearing of all used variables in this Script
   $AppLS                 = $null
   $ProgramList           = $null
   $CommandReturn         = $null
   $item                  = $null
   $pack                  = $null
   $packs                 = $null
   $service               = $null
   $services              = $null

   [GC]::Collect()
   #endregion cleanup

   # Do not reboot when NoRestart is True
   if (-not ($NoRestart))
   {
      Restart-Computer
   }
}
