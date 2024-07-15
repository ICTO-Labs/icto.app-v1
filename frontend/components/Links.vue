<script>
export default {
    name: 'Links',
    props: {
        links: {
            type: Array,
            default: () => []
        }
    },
    methods: {
        getIconClass(link) {
            const url = new URL(link);
            const domain = url.hostname;

            const iconMap = {
                'twitter.com': 'fab fa-twitter',
                'x.com': 'fab fa-twitter',
                'x.com': 'fab fa-twitter',
                't.me': 'fab fa-telegram',
                'telegram.me': 'fab fa-telegram',
                'github.com': 'fab fa-github',
                'discord.com': 'fab fa-discord',
                'discord.gg': 'fab fa-discord',
                'facebook.com': 'fab fa-facebook-f',
                'youtube.com': 'fab fa-youtube'
            };

            for (const [key, value] of Object.entries(iconMap)) {
                if (domain.includes(key)) {
                    return `${value} fs-4`;
                }
            }

            return 'fas fa-globe fs-4';
        }
    }
}
</script>
<template>
    <div>
        <a v-for="(link, index) in links" :key="index" :href="link" target="_blank" rel="noopener noreferrer"
            class="btn btn-icon me-3 btn-sm">
            <i :class="getIconClass(link)"></i>
        </a>
    </div>
</template>