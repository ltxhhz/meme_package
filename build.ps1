dart run build_runner build

# https://github.com/pinchbv/floor/issues/771
# 指定文件路径
$file_path = "lib\db\app_db.g.dart"

# 读取文件内容
$file_content = Get-Content -Path $file_path -Raw

$regex = [regex]::new("(Future<int\?> getMaxSequence\(\)[\S\s]+?\.query)(\([\S\s]+?row\.values\.first as int)")

# 判断是否匹配正则表达式
if ($regex.IsMatch($file_content)) {
    # 替换匹配的内容
    $new_content = $regex.Replace($file_content, {
        param($match)
        return $match.Groups[1].Value + "<int?>" + $match.Groups[2].Value + "?"
    })

    # 将修改后的内容写回文件
    Set-Content -Path $file_path -Value $new_content

    Write-Host "modify success"
} else {
    Write-Host "not found"
}