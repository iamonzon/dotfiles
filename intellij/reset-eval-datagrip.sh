rm -rf ~/.config/JetBrains/DataGrip**/eval
sed -i -E 's/<property name=\"evl.*\".*\/>//' ~/.config/JetBrains/DataGrip*/options/other.xml
rm -rf ~/.java/.userPrefs/jetbrains/datagrip
