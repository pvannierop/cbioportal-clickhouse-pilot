insert into sample_in_data_profile
select * from mysql('cbioDB:3306', 'cbioportal', 'view_sample_in_data_profile', 'cbio', 'P@ssword1');

