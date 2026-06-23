import urllib.request
import urllib.parse
import json
import os
import time

universities = [
    ("University of Health and Allied Sciences", "uhas"),
    ("University of Environment and Sustainable Development", "uesd"),
    ("Ghana Communication Technology University", "gctu"),
    ("Accra Technical University", "atu"),
    ("Cape Coast Technical University", "cctu"),
    ("Kumasi Technical University", "kstu"),
    ("Sunyani Technical University", "stu"),
    ("Ho Technical University", "htu"),
    ("Koforidua Technical University", "ktu"),
    ("Tamale Technical University", "tatu"),
    ("Bolgatanga Technical University", "btu"),
    ("Dr. Hilla Limann Technical University", "dhltu"),
    ("Methodist University Ghana", "mug"),
    ("Presbyterian University, Ghana", "pug"),
    ("Christian Service University", "csu"),
    ("Catholic University of Ghana", "cug"),
    ("KAAF University College", "kaaf"),
    ("Ensign Global College", "egu"),
    ("African University College of Communications", "aucb"),
    ("Wisconsin International University College, Ghana", "wiuc_ghana"),
    ("Knutsford University College", "kuc"),
    ("Regent University College of Science and Technology", "regent")
]

out_dir = "/Users/edwinrichardidan/projects/GitHub/CampusIQ/assets/images/universities"

def get_wiki_image_url(title):
    search_url = f"https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={urllib.parse.quote(title)}&utf8=&format=json"
    try:
        req = urllib.request.Request(search_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode())
            if not data['query']['search']: return None
            page_title = data['query']['search'][0]['title']
    except Exception as e:
        return None

    query_url = f"https://en.wikipedia.org/w/api.php?action=query&titles={urllib.parse.quote(page_title)}&prop=pageimages&format=json&pithumbsize=1000"
    try:
        req = urllib.request.Request(query_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode())
            pages = data['query']['pages']
            page_id = list(pages.keys())[0]
            if page_id == '-1': return None
            if 'thumbnail' in pages[page_id]:
                return pages[page_id]['thumbnail']['source']
            return None
    except Exception as e:
        return None

found_images = []

for name, abbr in universities:
    url = get_wiki_image_url(name)
    if url:
        print(f"Found image for {name}: {url}")
        filename = f"{abbr}.png"
        filepath = os.path.join(out_dir, filename)
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req, timeout=10) as response, open(filepath, 'wb') as out_file:
                out_file.write(response.read())
            print(f"Saved {filepath}")
            os.system(f"sips -s format png '{filepath}' --out '{filepath}' > /dev/null")
            found_images.append(abbr)
        except Exception as e:
            print(f"Failed to download {url}: {e}")
    else:
        print(f"No image found for {name}")
    time.sleep(0.5)

print("SUCCESSFULLY DOWNLOADED:", ",".join(found_images))
