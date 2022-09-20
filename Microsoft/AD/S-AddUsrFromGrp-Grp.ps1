Add-ADGroupMember -Identity 'gg_my_new_grp' -Members (Get-ADGroupMember -Identity 'gg_name_of_old_grp')
