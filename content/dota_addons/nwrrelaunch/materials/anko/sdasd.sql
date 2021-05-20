select pflegekraft.*, pflegekraft.last_activity as kontaktiert, `pflegekraft_berechnet`.`aktueller_status`, `pflegekraft_berechnet`.`aktueller_status_von`, `pflegekraft_berechnet`.`aktueller_status_bis`, `pflegekraft_berechnet`.`naechster_status`, `pflegekraft_berechnet`.`naechster_status_von`, `pflegekraft_berechnet`.`naechster_status_bis`, `pflegekraft_berechnet`.`verfuegbar`, `pflegekraft_berechnet`.`verfuegbar_dauer_wochen`, `pflegekraft_berechnet`.`erfahrungsstufe`, `pflegekraft_berechnet`.`platzierung`, `self_services`.`verfuegbar_ab` as `verfuegbarAb`, `self_services`.`season` as `seasonwork`, `self_services`.`arbeitet` as `arbeitet`, `self_services`.`impfstatus` as `impfstatus`, `self_services`.`comment` as `comment`, `self_services`.`updated_at` as `updatedAt`, `self_services`.`profile_image` as `profileImage`, `pflegekraft`.`rekrutiert_von` as `recruiter_id`, `pflegekraft`.`id` as `pkId`, `pflegekraft`.`vorname` as `vorname`, `pflegekraft`.`nachname` as `nachname` from `pflegekraft` left join `pflegekraft_berechnet` on `pflegekraft_berechnet`.`pflegekraft_id` = `pflegekraft`.`id` inner join `self_services` on `self_services`.`pflegekraft_id` = `pflegekraft`.`id` left join `users` on `users`.`id` = `pflegekraft`.`rekrutiert_von` order by `self_services`.`verfuegbar_ab` desc
