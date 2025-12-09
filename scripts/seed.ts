import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function seed() {
    // Seed clubs
    const club1 = await prisma.club.create({
        data: {
            name: 'Club A',
            location: 'City A',
            establishedYear: 2000,
        },
    });

    const club2 = await prisma.club.create({
        data: {
            name: 'Club B',
            location: 'City B',
            establishedYear: 2005,
        },
    });

    // Seed teams
    const team1 = await prisma.team.create({
        data: {
            name: 'Team A1',
            clubId: club1.id,
            category: 'Sub-14',
        },
    });

    const team2 = await prisma.team.create({
        data: {
            name: 'Team B1',
            clubId: club2.id,
            category: 'Aficionados',
        },
    });

    // Seed players
    await prisma.player.createMany({
        data: [
            {
                name: 'Player 1',
                age: 12,
                dorsal: 10,
                position: 'Forward',
                teamId: team1.id,
            },
            {
                name: 'Player 2',
                age: 13,
                dorsal: 9,
                position: 'Midfielder',
                teamId: team1.id,
            },
            {
                name: 'Player 3',
                age: 25,
                dorsal: 7,
                position: 'Defender',
                teamId: team2.id,
            },
        ],
    });

    console.log('Seeding completed.');
}

seed()
    .catch(e => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });