-- Cloud build proof-of-concept. Automated CI test.
-- This script is intentionally harmless and only proves that
-- source code can be packaged into a Roblox place in GitHub Actions.

local marker = workspace:FindFirstChild("CloudBuildTest")

if marker then
    marker:SetAttribute("BuiltBy", "GitHub Actions + Rojo")
    marker:SetAttribute("BuildTest", true)
end
