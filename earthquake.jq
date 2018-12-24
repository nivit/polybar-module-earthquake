if .metadata.count > 0 then

    if $what == "latest" then
        .features[0]
    else
        .features | max_by(.properties.mag)
    end

    |

    if $get == "coords" then
        .geometry.coordinates[1,0]?
    elif $get == "id" then
        .id?
    else
        .properties[$get]?
    end

else

    "No earthquake"
end
