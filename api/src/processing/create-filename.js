export default (f, style, isAudioOnly, isAudioMuted) => {
    let filename = '';

    let infoBase = [f.service, f.id];
    let classicTags = [...infoBase];
    let basicTags = [];

    const title = `${f.title} - ${f.author}`;

    if (f.resolution) {
        classicTags.push(f.resolution);
    }

    if (f.qualityLabel) {
        basicTags.push(f.qualityLabel);
    }

    if (f.youtubeFormat) {
        classicTags.push(f.youtubeFormat);
        basicTags.push(f.youtubeFormat);
    }

    if (isAudioMuted) {
        classicTags.push("mute");
        basicTags.push("mute");
    } else if (f.youtubeDubName) {
        classicTags.push(f.youtubeDubName);
        basicTags.push(f.youtubeDubName);
    }

    switch (style) {
        default:
        case "classic":
            if (isAudioOnly) {
                if (f.youtubeDubName) {
                    infoBase.push(f.youtubeDubName);
                }
                return `${infoBase.join("_")}_audio`;
            }
            filename = classicTags.join("_");
            break;
        case "basic":
            if (isAudioOnly) return title;
            filename = `${title} (${basicTags.join(", ")})`;
            break;
        case "pretty":
            if (isAudioOnly) return `${title} (${infoBase[0]})`;
            filename = `${title} (${[...basicTags, infoBase[0]].join(", ")})`;
            break;
        case "nerdy":
            if (isAudioOnly) return `${title} (${infoBase.join(", ")})`;
            filename = `${title} (${basicTags.concat(infoBase).join(", ")})`;
            break;
    }
    return `Tg: @teleservices_api ${filename}.${f.extension}`;
}
