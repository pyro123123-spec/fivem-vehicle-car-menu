// FiveM Vehicle Car Menü Script
// NUI Handler mit Datenbank Support

const musicMenu = document.getElementById('musicMenu');
const youtubeLink = document.getElementById('youtubeLink');
const submitBtn = document.getElementById('submitBtn');
const cancelBtn = document.getElementById('cancelBtn');
const musicPlayer = document.getElementById('musicPlayer');
const playerInfo = document.getElementById('playerInfo');
const stopBtn = document.getElementById('stopBtn');
const savedMusicList = document.getElementById('savedMusicList');

let currentPlayer = null;
let savedMusicLinks = [];

// Menu öffnen
function openMusicMenu(data) {
    musicMenu.classList.remove('hidden');
    youtubeLink.value = '';
    youtubeLink.focus();
    
    // Gespeicherte Musik anzeigen
    if (data && data.savedMusic) {
        displaySavedMusic(data.savedMusic);
    }
}

// Menu schließen
function closeMusicMenu() {
    musicMenu.classList.add('hidden');
    youtubeLink.blur();
}

// Gespeicherte Musik anzeigen
function displaySavedMusic(musicArray) {
    savedMusicLinks = musicArray || [];
    
    if (!savedMusicList) return;
    
    savedMusicList.innerHTML = '';
    
    if (musicArray && musicArray.length > 0) {
        musicArray.forEach((link, index) => {
            const linkElement = document.createElement('div');
            linkElement.className = 'saved-music-item';
            linkElement.innerHTML = `
                <span class="music-link-text" title="${link}">${link.substring(0, 50)}...</span>
                <div>
                    <button class="music-link-btn" onclick="loadSavedMusic('${link}')">Abspielen</button>
                    <button class="music-link-delete" onclick="deleteSavedMusic('${link}')">✕</button>
                </div>
            `;
            savedMusicList.appendChild(linkElement);
        });
    } else {
        savedMusicList.innerHTML = '<p style="color: #808080;">Keine gespeicherten Links</p>';
    }
}

// Gespeicherte Musik laden und abspielen
function loadSavedMusic(link) {
    youtubeLink.value = link;
    submitBtn.click();
}

// Gespeicherte Musik löschen
function deleteSavedMusic(link) {
    if (confirm('Möchtest du diesen Link wirklich löschen?\n\n' + link)) {
        fetch(`https://${GetParentResourceName()}/carMenu:deleteMusic`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                youtubeLink: link
            })
        });
        
        // Lokal entfernen
        savedMusicLinks = savedMusicLinks.filter(l => l !== link);
        displaySavedMusic(savedMusicLinks);
    }
}

// Musik abspielen
function playMusic(link) {
    if (!link || link.trim() === '') {
        showError('Bitte gebe einen gültigen Link ein!');
        return;
    }
    
    // YouTube Link validieren
    if (!isValidYouTubeLink(link)) {
        showError('Ungültiger YouTube Link!');
        return;
    }
    
    // Embed Link generieren
    const embedLink = convertToEmbedLink(link);
    
    playerInfo.innerHTML = `
        <strong>Link:</strong> ${link}<br>
        <strong>Status:</strong> <span style="color: #00cc00;">▶ Wird abgespielt...</span>
    `;
    
    musicPlayer.classList.remove('hidden');
    
    // An Server senden
    fetch(`https://${GetParentResourceName()}/carMenu:musicStarted`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            link: link
        })
    });
}

// Musik stoppen
function stopMusic() {
    musicPlayer.classList.add('hidden');
    playerInfo.innerHTML = '';
    youtubeLink.value = '';
}

// YouTube Link validieren
function isValidYouTubeLink(url) {
    const youtubeRegex = /(https?:\/\/)?(www\.)?(youtube|youtu|youtube-nocookie)\.(com|be)\//;
    return youtubeRegex.test(url);
}

// In Embed Link umwandeln
function convertToEmbedLink(url) {
    let videoId = '';
    
    if (url.includes('youtube.com')) {
        videoId = url.split('v=')[1];
        if (videoId && videoId.includes('&')) {
            videoId = videoId.split('&')[0];
        }
    } else if (url.includes('youtu.be')) {
        videoId = url.split('youtu.be/')[1];
        if (videoId && videoId.includes('?')) {
            videoId = videoId.split('?')[0];
        }
    }
    
    return `https://www.youtube.com/embed/${videoId}`;
}

// Fehler anzeigen
function showError(message) {
    playerInfo.innerHTML = `<strong style="color: #cc0000;">❌ Fehler:</strong> ${message}`;
    musicPlayer.classList.remove('hidden');
}

// Event Listener
submitBtn.addEventListener('click', function() {
    const link = youtubeLink.value.trim();
    if (link !== '') {
        playMusic(link);
    } else {
        showError('Bitte gebe einen Link ein!');
    }
});

cancelBtn.addEventListener('click', function() {
    closeMusicMenu();
    fetch(`https://${GetParentResourceName()}/ui:closed`, {
        method: 'POST'
    });
});

stopBtn.addEventListener('click', function() {
    stopMusic();
});

youtubeLink.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        submitBtn.click();
    }
});

// NUI Messages vom Client empfangen
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'openMusicMenu') {
        openMusicMenu(data);
    } else if (data.type === 'closeMusicMenu') {
        closeMusicMenu();
    } else if (data.type === 'playMusic') {
        playMusic(data.link);
    } else if (data.type === 'stopMusic') {
        stopMusic();
    }
});

// Escape key zum Schließen
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeMusicMenu();
    }
});

console.log('%c[Vehicle Car Menü] NUI Script mit Datenbank Support geladen!', 'color: #ffd700; font-weight: bold;');
