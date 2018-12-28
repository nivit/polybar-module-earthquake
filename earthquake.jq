if .metadata.count > 0 then

    if $what == "latest" then
        .features[0]
    elif $what == "max" then
        .features | max_by(.properties.mag)
    else
        .features[]
    end

    |

    if $get == "coords" then
        [.geometry.coordinates[1,0]?] | tostring | ltrimstr("[") | rtrimstr("]")
    elif $get == "id" then
        .id?
    else
        (.properties.time? / 1000 | todate),
        .geometry.coordinates[1,0]?,
        .id?,
        .properties.mag?,
        .properties.title?,
        .properties.tsunami?,
        .properties.url?
    end

else

    "No earthquake"
end
