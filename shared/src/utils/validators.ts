export const validateEmail = (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
};

export const validatePassword = (password: string): boolean => {
    return password.length >= 6;
};

export const validatePlayerData = (player: {
    name: string;
    age: number;
    dorsal: number;
    position: string;
}): boolean => {
    return (
        player.name.trim() !== '' &&
        player.age > 0 &&
        player.dorsal > 0 &&
        player.position.trim() !== ''
    );
};

export const validateTeamData = (team: {
    name: string;
    category: string;
}): boolean => {
    return (
        team.name.trim() !== '' &&
        team.category.trim() !== ''
    );
};