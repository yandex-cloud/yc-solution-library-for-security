#Скрипт предназанчен для получения списка ролей для пользователейб групп и сервисных учеток. Роли вычитываются 
#на уровне организации, облака и фолдера по отдельности
#есть возможность указать фильтр для организации и облака
#запускать необходимо с ролью, имеющей, как минимум, viewer на все запрашиваемые контейнеры
#скрипт выводит в CSV файл таблицу, в каждой строке которой содержится инофрмация об одной роли, субъекте и к какому объекту эта роль назначена
#анализировать желательно в Excel или, например, в Data Lens
$filePath = "yc_roles.csv"
#установите значение max_user_count, гарантированно перекрывающее максимальное количество пользователей в любой вашей организации
$max_user_count = 25000
$use_orgs_filter = $false
#формат фильтра - массив @("b1giodvrq10i1s552158", "b1gp1d7evq3spemmkb37")
$orgs_filter = @("bpfi6o0mvliepdcf1610")
$use_clouds_filter = $false
$clouds_filter = @("b1giodvrq10i1s552158", "b1gp1d7evq3spemmkb37")
$header = "Level;OrgName;OrgID;CloudName;CloudID;FolderName;FolderID;Role;SubjectType;SubjectID;SubjectName"
$users = $null
$groups = $null
$outString = New-Object System.Collections.Generic.List[System.Object]

if ( $use_orgs_filter ) {
    write-host "Используется фильтр по организации. В случае ошибок проверьте правильность id организаций в фильтре." -ForegroundColor Yellow
    $orgs = @()
    foreach ($id in $orgs_filter) {
        $o_temp = yc organization-manager organization get --id $id --format=json | ConvertFrom-Json
        $orgs += $o_temp
    }
}
else {
  $orgs = yc organization-manager organization list --format=json | ConvertFrom-Json
}  
$i_org = 0
$p_org = 0
foreach ($o in $orgs) {
    #Собираем Hash список по польователям и сервисным учеткам
    $i_org += 1
    $p_org = ($i_org / $orgs.Count) * 100
    Write-Progress -Id 0 "Рвботаем с организацией - $($o.name)..." -PercentComplete $p_org
    $users_list = yc organization-manager user list --organization-id $o.id --limit $max_user_count --format=json | ConvertFrom-Json
    $users = @{}
    foreach ($u in $users_list) {
        if ( $u.subject_claims.preferred_username -eq $null) {
            $users.Add($u.subject_claims.sub, $u.subject_claims.name) 
        }
        else { 
            $users.Add($u.subject_claims.sub, $u.subject_claims.preferred_username) 
        }
    }
    #Собираем Hash список по группам
    $groups = @{}
    #две последующие строки нужны для фильтрации сценария, где в орге нет групп
    $raw_group_list = yc organization-manager group list --organization-id $o.id --format=json
    if ( $raw_group_list.count -gt 2 ) {
        $group_list = $raw_group_list | ConvertFrom-Json
        foreach ($g in $group_list) {
            $groups.Add($g.id, $g.name)
        }
    }
    #Собираем роли на уровне орги
    $org_bingings = yc organization-manager organization list-access-bindings $o.id --format=json | ConvertFrom-Json
    foreach ($b in $org_bingings) {
        $s = "Org;$($o.name);$($o.id);;;;;$($b.role_id);$($b.subject.type);$($b.subject.id)"
        $outString.Add($s)
    }
    if ( $use_clouds_filter ) {
        write-host "Используется фильтр по облакам. В случае ошибок проверьте правильность id облаков в фильтре." -ForegroundColor Yellow
        $clouds = @()
        foreach ($id in $clouds_filter) {
            $c_temp = yc resource-manager cloud get --id $id --format=json | ConvertFrom-Json
            $clouds += $c_temp
        }
    }
    else {
        $raw_clouds = yc resource-manager cloud list --organization-id=$ORG_ID --format=json
        if ( $raw_clouds.count -gt 2 ) {
            $clouds = $raw_clouds | ConvertFrom-Json
        }
        else {
            $clouds = @()
        }        
    }
    $i_cloud = 0
    $p_cloud = 0  
    foreach ($c in $clouds) {
        $i_cloud += 1
        $p_cloud = ($i_cloud / $clouds.Count) * 100
        Write-Progress -Id 1  -ParentId 0 "Рвботаем с облаком - $($c.name)..." -PercentComplete $p_cloud
        #Собираем роли на уровне облака
        $cloud_bingings = yc resource-manager cloud list-access-bindings $c.id --format=json | ConvertFrom-Json
        foreach ($b in $cloud_bingings) {
            $s = "Cloud;$($o.name);$($o.id);$($c.name);$($c.id);;;$($b.role_id);$($b.subject.type);$($b.subject.id)"
            $outString.Add($s)
        } 
        $raw_folders = yc resource-manager folder list --cloud-id=$($c.id) --format=json 
        if ( $raw_folders.count -gt 2 ) {
            $folders = $raw_folders | ConvertFrom-Json
        }
        else {
            $folders = @()
        }
        $i_folder = 0
        $p_folder = 0  
        foreach ($f in $folders) {
            $i_folder += 1
            $p_folder = ($i_folder / $folders.Count) * 100
            #пополняем список пользователей и сервисных учеток учетками sa на уровне папки
            Write-Progress -Id 2  -ParentId 1 "Рвботаем с фолдером - $($f.name)..." -PercentComplete $p_folder
            $raw_sa_list = yc iam service-account list --folder-id $($f.id) --format=json
            if ( $raw_sa_list.count -gt 2 ) { 
                $sa_list = $raw_sa_list | ConvertFrom-Json           
                foreach ($sa in $sa_list) {
                    if ($users[$sa.id].Length -eq 0 ) {
                        $users.Add($sa.id,$sa.name)
                    }
                }
            }
            #Собираем роли на уровне фолдера
            $folder_bingings = yc resource-manager folder list-access-bindings $f.id --format=json | ConvertFrom-Json
            foreach ($b in $folder_bingings) {
                $s = "Folder;$($o.name);$($o.id);$($c.name);$($c.id);$($f.name);$($f.id);$($b.role_id);$($b.subject.type);$($b.subject.id)"
                $outString.Add($s)
            }
        }
    }
}
Write-Progress -Activity "Разрешаем имена пользователей"
$out = New-Object System.Collections.Generic.List[System.Object]
$out.Add($header)
#разрешаем id учеток в их имена
foreach ($s in $outString) {
    $type = $s.Split(";")[-2]
    $id = $s.Split(";")[-1]
    switch ($type) {
        "group" { $subject_name = $groups[$id] }
        default { $subject_name = $users[$id] }
    }
    $out.Add("$s;$subject_name")
}
Set-Content -Path $filePath -Value $out

