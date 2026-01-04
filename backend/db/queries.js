import schemaCjs from './schema.js';
const [Password_Builder, Password_Builder_Test] = schemaCjs;
import { connect, disconnect } from 'mongoose';


// import { readPassword } from './read_file.cjs';
import readPassword from './read_file.js';
import { DuplicateEntry } from '../api/error.js';


async function create_password_table() {

    const {site, username, password} = readPassword();


    for (let index = 0; index < site.length; index++) {
        // create new Password
        const passwords = new Password_Builder({
            site: site[index],
            user_name: username[index],
            password: password[index],
        });
        await passwords.save(); // saves to the database
        
    }
}

async function create_sites_table() {

    const {site, username, password} = readPassword();


    for (let index = 0; index < site.length; index++) {
        try {
            // Create Sites Database
            const sites = new Sites({
                site: site[index],
            });
            await sites.save(); // saves to the database
            console.log('Sites data created');
        } catch (error) {
            console.log('Duplicate Entry found\nMove Forward');
        };
    }
}

export async function create_user(username, password) {
    
}

export async function display_password() {
    // read all Password_Builders
    const Password_Builders = await Password_Builder.find();
    
    for (let index = 0; index < Password_Builders.length; index++) {
        Password_Builders[index].show_password();
        console.log('\n');
        
    }
    
}

export async function find_password(site_name) {
    // read all Password_Builders
    const Password_Builders = await Password_Builder.find({"site": site_name});

    let username = [], password = [];


    for (let index = 0; index < Password_Builders.length; index++) {
        [username[index], password[index]] = Password_Builders[index].show_user_password();
        console.log(`user_name: ${username[index]}\npassword: ${password[index]}`);
        
    }
    
    return [username, password];
}

export async function get_sites() {
    const SitesData = await Password_Builder.get_sites();

    let site_name = [];

    for (let index = 0; index < SitesData.length; index++) {
        site_name[index] = SitesData[index];
        
    }

    return site_name;

}

export async function get_selected_sites(site_name) {
    const SitesData = await Password_Builder.get_selected_sites(site_name);

    let site_names = [];

    for (let index = 0; index < SitesData.length; index++) {
        site_names[index] = SitesData[index];
    }

    return site_names;

}


/*
* Function: Add_password
* Purpose: Add the encrypted password to the DB
*/
export async function add_password(site_name, username, password) {
    await connect('mongodb://127.0.0.1:27017/Password_Keepers');
    const testUser = new Password_Builder_Test({
        site: site_name,
        user_name: username,
        password: password
    })
    
    try {
        const result = await testUser.save();
        console.log('Inserted document with ID:', result);
      } catch (err) {
        console.error('Error inserting document:', err);
        throw new DuplicateEntry();
      }
      finally {
        disconnect();
      }
    
    
}

/*
* Function: Update_password
* Purpose: Updates the encrypted password in the DB
*/
export async function update_password(site_name, username, password) {
    await connect('mongodb://127.0.0.1:27017/Password_Keepers');
    
    try {
        // Define the filter and update
        const filter = { site: site_name, user_name: username }; // filter criteria
        const update = { password: password }; // update operation
    
        const result = await Password_Builder_Test.updateOne(filter, { $set: update });
        console.log('Updated document:', result);
    
        // Optionally, update multiple documents
        // const updateManyResult = await User.updateMany(filter, { $set: update });
        // console.log('Updated documents:', updateManyResult);
      } catch (err) {
        console.error(err);
        throw err;
      } finally {
        disconnect();
      }
    
    
}

/*
* Function: Backup 
* Purpose: Backup DB passwords with ecryption key
*/
export async function backup() {
    await connect('mongodb://127.0.0.1:27017/Password_Keepers');
    
    try {
        const allDocuments = await Password_Builder.find();
        console.log(allDocuments);
      } catch (err) {
        console.error(err);
        throw err;
      } finally {
        disconnect();
      }
}




