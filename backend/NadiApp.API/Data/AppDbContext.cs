using NadiApp.API.Models;
using Microsoft.EntityFrameworkCore;

namespace NadiApp.API.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Court> Courts => Set<Court>();
    public DbSet<Reservation> Reservations => Set<Reservation>();
    public DbSet<Notification> Notifications => Set<Notification>();

    protected override void OnModelCreating(ModelBuilder m)
    {
        m.Entity<Reservation>()
            .HasOne(r => r.User)
            .WithMany(u => u.Reservations)
            .HasForeignKey(r => r.UserId);

        m.Entity<Reservation>()
            .HasOne(r => r.Court)
            .WithMany(c => c.Reservations)
            .HasForeignKey(r => r.CourtId);

        m.Entity<Court>()
            .Property(c => c.HourlyRate)
            .HasPrecision(10, 2);

        m.Entity<Reservation>()
            .Property(r => r.TotalPrice)
            .HasPrecision(10, 2);

        m.Entity<Reservation>()
            .Property(r => r.DepositAmount)
            .HasPrecision(10, 2);
    }
}