insert into sample_in_genetic_profile
select * from mysql(
    'cbioDB:3306',
    'cbioportal',
    'view_sample_in_genetic_profile',
    'cbio',
    'P@ssword1'
);
