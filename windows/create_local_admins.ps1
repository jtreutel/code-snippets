#-------------------------------------------
# Create Some Local Admin Test Accts on a Nonprod Server
#-------------------------------------------

$Password = ConvertTo-SecureString -String "SomeRandomPassword123!@#" -AsPlainText -Force
New-LocalUser "foo.bar" -Password $Password
New-LocalUser "bar.baz" -Password $Password
New-LocalUser "baz.bat" -Password $Password
Add-LocalGroupMember -Group "Administrators" -Member "foo.bar", "bar.baz", "baz.bat"